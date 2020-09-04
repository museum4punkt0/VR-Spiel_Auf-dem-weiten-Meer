// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "StartIslandTerrain"
{
	Properties
	{
		_TilingHeightMask("TilingHeightMask", Vector) = (0,0,0,0)
		_HeightACol("HeightACol", Color) = (0,0,0,0)
		_HeightBCol("HeightBCol", Color) = (0,0,0,0)
		_HeightShadowCol("HeightShadowCol", Color) = (0,0,0,0)
		_MaskBeach("MaskBeach", 2D) = "white" {}
		_TilingBeachMask("TilingBeachMask", Vector) = (0,0,0,0)
		_BeachFalloff("BeachFalloff", Range( 0 , 1)) = 0
		_BeachACol("BeachACol", Color) = (0,0,0,0)
		_BeachBCol("BeachBCol", Color) = (0,0,0,0)
		_BeachShadowCol("BeachShadowCol", Color) = (0,0,0,0)
		_ShadowSharpness("ShadowSharpness", Float) = 0
		_ShadowOffset("ShadowOffset", Float) = 0
		_StartPoint("Start Point", Float) = 0
		_Distribution("Distribution", Range( 0.1 , 10)) = 4.8
		_FresnelCol("FresnelCol", Color) = (0,0,0,0)
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		_FresnelBiasVal("FresnelBiasVal", Float) = 0
		_FresnelScale("FresnelScale", Float) = 0
		_Float0("Float 0", Float) = 0
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#define ASE_TEXTURE_PARAMS(textureName) textureName

		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float4 _BeachACol;
		uniform float4 _BeachBCol;
		uniform sampler2D _MaskBeach;
		uniform float2 _TilingBeachMask;
		uniform float _BeachFalloff;
		uniform float4 _BeachShadowCol;
		uniform float _ShadowOffset;
		uniform float _ShadowSharpness;
		uniform float4 _HeightACol;
		uniform float _FresnelBiasVal;
		uniform float _FresnelScale;
		uniform float _Float0;
		uniform float4 _FresnelCol;
		uniform float4 _HeightBCol;
		uniform sampler2D _TextureSample0;
		uniform float2 _TilingHeightMask;
		uniform float4 _HeightShadowCol;
		uniform float _StartPoint;
		uniform float _Distribution;


		inline float4 TriplanarSamplingSF( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
		{
			float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
			projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
			float3 nsign = sign( worldNormal );
			half4 xNorm; half4 yNorm; half4 zNorm;
			xNorm = ( tex2D( ASE_TEXTURE_PARAMS( topTexMap ), tiling * worldPos.zy * float2( nsign.x, 1.0 ) ) );
			yNorm = ( tex2D( ASE_TEXTURE_PARAMS( topTexMap ), tiling * worldPos.xz * float2( nsign.y, 1.0 ) ) );
			zNorm = ( tex2D( ASE_TEXTURE_PARAMS( topTexMap ), tiling * worldPos.xy * float2( -nsign.z, 1.0 ) ) );
			return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
		}


		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 ase_vertexNormal = mul( unity_WorldToObject, float4( ase_worldNormal, 0 ) );
			float4 triplanar47 = TriplanarSamplingSF( _MaskBeach, ase_vertex3Pos, ase_vertexNormal, _BeachFalloff, _TilingBeachMask, 1.0, 0 );
			float4 lerpResult82 = lerp( _BeachACol , _BeachBCol , triplanar47.x);
			float3 ase_normWorldNormal = normalize( ase_worldNormal );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult59 = dot( ase_normWorldNormal , ase_worldlightDir );
			float clampResult67 = clamp( ( ( dotResult59 + _ShadowOffset ) * _ShadowSharpness ) , 0.0 , 1.0 );
			float clampResult69 = clamp( ( ase_lightAtten * clampResult67 ) , 0.0 , 1.0 );
			float temp_output_89_0 = ( 1.0 - clampResult69 );
			float4 lerpResult78 = lerp( lerpResult82 , _BeachShadowCol , temp_output_89_0);
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float fresnelNdotV16 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode16 = ( _FresnelBiasVal + _FresnelScale * pow( 1.0 - fresnelNdotV16, _Float0 ) );
			float4 blendOpSrc101 = _HeightACol;
			float4 blendOpDest101 = ( fresnelNode16 * _FresnelCol );
			float2 appendResult95 = (float2(ase_vertex3Pos.x , ase_vertex3Pos.y));
			float4 lerpResult86 = lerp( ( saturate( 	max( blendOpSrc101, blendOpDest101 ) )) , _HeightBCol , tex2D( _TextureSample0, ( appendResult95 * _TilingHeightMask ) ).r);
			float4 lerpResult88 = lerp( lerpResult86 , _HeightShadowCol , temp_output_89_0);
			float4 lerpResult28 = lerp( lerpResult78 , lerpResult88 , saturate( ( ( ase_vertex3Pos.y + _StartPoint ) / _Distribution ) ));
			c.rgb = lerpResult28.rgb;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float4 tSpace0 : TEXCOORD1;
				float4 tSpace1 : TEXCOORD2;
				float4 tSpace2 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16900
49.6;263.2;1731;737;2547.019;657.4974;1.733584;True;True
Node;AmplifyShaderEditor.CommentaryNode;50;-1155.781,-2192.757;Float;False;836.6255;384.7068;Comment;3;59;58;57;WorldDotLight;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;58;-940.3571,-2135.033;Float;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;51;-278.7754,-2175.727;Float;False;1082.442;371.774;Shadowmask (no color);8;69;68;67;66;65;64;63;61;Toon-ify lights/shadows;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;57;-952.8491,-1977.781;Float;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;61;-223.0193,-2009.808;Float;False;Property;_ShadowOffset;ShadowOffset;13;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;59;-689.2061,-2039.007;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;64;-228.7743,-1918.953;Float;False;Property;_ShadowSharpness;ShadowSharpness;12;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;63;-3.217613,-2067.377;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;104;-1962.802,60.20654;Float;False;Property;_Float0;Float 0;25;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;102;-1994.006,-127.0206;Float;False;Property;_FresnelBiasVal;FresnelBiasVal;23;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;94;-1300.305,-285.5802;Float;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;130.9455,-2045.505;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;25;-1978.882,-295.6741;Float;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;103;-1995.74,-43.80852;Float;False;Property;_FresnelScale;FresnelScale;24;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;67;279.4368,-1975.535;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;90;-1298.968,71.78848;Float;False;Property;_TilingHeightMask;TilingHeightMask;1;0;Create;True;0;0;False;0;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.ColorNode;19;-1791.94,33.19324;Float;False;Property;_FresnelCol;FresnelCol;16;0;Create;True;0;0;False;0;0,0,0,0;1,0.7817016,0.4292451,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LightAttenuation;66;143.8821,-2131.526;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;95;-1055.27,-254.5488;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FresnelNode;16;-1688.281,-227.6845;Float;False;Standard;WorldNormal;ViewDir;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-1389.576,-1159.749;Float;False;Property;_StartPoint;Start Point;14;0;Create;True;0;0;False;0;0;-13.35;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;453.1007,-2008.167;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;93;-1373.318,-549.5772;Float;False;Property;_BeachFalloff;BeachFalloff;8;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;33;-1274.192,-1329.354;Float;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-1366.354,-125.7643;Float;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;100;-1026.252,-384.1479;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;91;-1388.713,-808.6899;Float;False;Property;_TilingBeachMask;TilingBeachMask;7;0;Create;True;0;0;False;0;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.ColorNode;83;-610.3246,-470.2655;Float;False;Property;_HeightACol;HeightACol;3;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;1;-632.976,-1177.927;Float;False;Property;_BeachACol;BeachACol;9;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BlendOpsNode;101;-296.2996,-515.9243;Float;True;Lighten;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.TriplanarNode;47;-1082.406,-946.1329;Float;True;Spherical;Object;False;MaskBeach;_MaskBeach;white;6;None;Mid Texture 0;_MidTexture0;white;-1;None;Bot Texture 0;_BotTexture0;white;-1;None;Triplanar Sampler;False;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;84;-522.8644,-62.56186;Float;False;Property;_HeightBCol;HeightBCol;4;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;35;-757.0005,-1326.096;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;69;623.9789,-2003.599;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;96;-868.3873,-351.9646;Float;True;Property;_TextureSample0;Texture Sample 0;22;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;80;-641.556,-981.4898;Float;False;Property;_BeachBCol;BeachBCol;10;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;37;-916.0714,-1526.483;Float;False;Property;_Distribution;Distribution;15;0;Create;True;0;0;False;0;4.8;3.21;0.1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;87;-518.0351,123.4462;Float;False;Property;_HeightShadowCol;HeightShadowCol;5;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;89;602.479,-1409.819;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;86;-164.8092,-155.4744;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;81;-593.8354,-783.5674;Float;False;Property;_BeachShadowCol;BeachShadowCol;11;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;82;-240.6094,-1062.488;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;36;-463.6497,-1348.82;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;88;56.5524,-109.4134;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;49;-2003.235,-2187.696;Float;False;831.9146;313.1678;Comment;2;54;53;Normals;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;38;-178.7259,-1418.405;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;78;-8.520704,-989.4067;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;48;-884.6605,434.4556;Float;False;738.0623;399.4987;Comment;5;43;46;41;45;42;Fog;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;98;-1515.788,-385.7644;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;44;1261.607,-948.8049;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;54;-1695.431,-2139.203;Float;True;Property;_Normals;Normals;20;0;Create;True;0;0;False;0;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;53;-1961.449,-2085.76;Float;False;Property;_NormalScale;Normal Scale;21;0;Create;True;0;0;False;0;0;-1;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;28;335.4741,-1013.568;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-834.4858,576.429;Float;False;Property;_Distance;Distance;18;0;Create;True;0;0;False;0;0;50;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CameraDepthFade;41;-605.662,484.4556;Float;False;3;2;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TriplanarNode;85;-1006.606,-39.11924;Float;True;Spherical;Object;False;MaskHeight;_MaskHeight;white;0;None;Mid Texture 1;_MidTexture1;white;-1;None;Bot Texture 1;_BotTexture1;white;-1;None;Triplanar Sampler;False;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;79;-1406.793,-1455.813;Float;False;Object Position;-1;;2;b9555b68a3d67c54f91597a05086026a;0;0;4;FLOAT3;7;FLOAT;0;FLOAT;4;FLOAT;5
Node;AmplifyShaderEditor.RangedFloatNode;92;-1284.119,248.814;Float;False;Property;_HeightFalloff;HeightFalloff;2;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;45;-422.2862,626.9543;Float;False;Property;_FogCol;FogCol;17;0;Create;True;0;0;False;0;0,0,0,0;0.6616233,0.7924528,0.730886,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;43;-834.6605,495.8366;Float;False;Property;_Falloff;Falloff;19;0;Create;True;0;0;False;0;0;286.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DesaturateOpNode;46;-350.5982,488.8519;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1549.226,-487.9984;Float;False;True;2;Float;ASEMaterialInspector;0;0;CustomLighting;StartIslandTerrain;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;59;0;58;0
WireConnection;59;1;57;0
WireConnection;63;0;59;0
WireConnection;63;1;61;0
WireConnection;65;0;63;0
WireConnection;65;1;64;0
WireConnection;67;0;65;0
WireConnection;95;0;94;1
WireConnection;95;1;94;2
WireConnection;16;0;25;0
WireConnection;16;1;102;0
WireConnection;16;2;103;0
WireConnection;16;3;104;0
WireConnection;68;0;66;0
WireConnection;68;1;67;0
WireConnection;20;0;16;0
WireConnection;20;1;19;0
WireConnection;100;0;95;0
WireConnection;100;1;90;0
WireConnection;101;0;83;0
WireConnection;101;1;20;0
WireConnection;47;3;91;0
WireConnection;47;4;93;0
WireConnection;35;0;33;2
WireConnection;35;1;34;0
WireConnection;69;0;68;0
WireConnection;96;1;100;0
WireConnection;89;0;69;0
WireConnection;86;0;101;0
WireConnection;86;1;84;0
WireConnection;86;2;96;1
WireConnection;82;0;1;0
WireConnection;82;1;80;0
WireConnection;82;2;47;1
WireConnection;36;0;35;0
WireConnection;36;1;37;0
WireConnection;88;0;86;0
WireConnection;88;1;87;0
WireConnection;88;2;89;0
WireConnection;38;0;36;0
WireConnection;78;0;82;0
WireConnection;78;1;81;0
WireConnection;78;2;89;0
WireConnection;44;0;28;0
WireConnection;44;1;45;0
WireConnection;44;2;46;0
WireConnection;54;5;53;0
WireConnection;28;0;78;0
WireConnection;28;1;88;0
WireConnection;28;2;38;0
WireConnection;41;0;43;0
WireConnection;41;1;42;0
WireConnection;85;3;90;0
WireConnection;85;4;92;0
WireConnection;46;0;41;0
WireConnection;0;13;28;0
ASEEND*/
//CHKSM=65FD626E8C100318A55868D39DB94756333F8CD5