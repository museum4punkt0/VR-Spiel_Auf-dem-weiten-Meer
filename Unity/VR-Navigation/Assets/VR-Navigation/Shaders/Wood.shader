// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Wood"
{
	Properties
	{
		_SpecularColor("Specular Color", Color) = (1,1,1,1)
		_Shininess("Glossiness", Float) = 0
		_ShadowCol("ShadowCol", Color) = (0,0,0,0)
		_FresnelCol("FresnelCol", Color) = (0,0,0,0)
		_GroundBounceCol("GroundBounceCol", Color) = (0,0,0,0)
		_SkyBounceCol("SkyBounceCol", Color) = (0,0,0,0)
		_ShadowOffset("ShadowOffset", Float) = 0
		_LightTex("LightTex", 2D) = "white" {}
		_ShadowSharpness("ShadowSharpness", Float) = 0
		_NormalsTex("NormalsTex", 2D) = "bump" {}
		_DiffuseTex("DiffuseTex", 2D) = "white" {}
		_ToonRampTex("ToonRampTex", 2D) = "white" {}
		_PowerVal("PowerVal", Float) = 0
		_BiasVal("BiasVal", Float) = 0
		_ScaleVal("ScaleVal", Float) = 0
		_SpecularMaskTex("SpecularMaskTex", 2D) = "white" {}
		_ShadowDetail("ShadowDetail", Range( 0 , 1)) = 0
		_NightCol("NightCol", Color) = (0.1501615,0,0.9339623,0)
		_NightBounceCol("NightBounceCol", Color) = (0.1501615,0,0.9339623,0)
		_XToonVal("XToonVal", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
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
			float2 uv_texcoord;
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

		uniform float4 _NightCol;
		uniform float NightTransitionMaterial;
		uniform float4 _ShadowCol;
		uniform sampler2D _DiffuseTex;
		uniform float4 _DiffuseTex_ST;
		uniform float _ShadowDetail;
		uniform float _BiasVal;
		uniform float _ScaleVal;
		uniform float _PowerVal;
		uniform float4 _FresnelCol;
		uniform half _Shininess;
		uniform half4 _SpecularColor;
		uniform sampler2D _SpecularMaskTex;
		uniform float4 _SpecularMaskTex_ST;
		uniform sampler2D _ToonRampTex;
		uniform float _XToonVal;
		uniform sampler2D _LightTex;
		uniform float4 _LightTex_ST;
		uniform sampler2D _NormalsTex;
		uniform float4 _NormalsTex_ST;
		uniform float _ShadowOffset;
		uniform float _ShadowSharpness;
		uniform float4 _SkyBounceCol;
		uniform float4 _GroundBounceCol;
		uniform float4 _NightBounceCol;

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
			float4 lerpResult142 = lerp( float4( 1,1,1,0 ) , _NightCol , NightTransitionMaterial);
			float2 uv_DiffuseTex = i.uv_texcoord * _DiffuseTex_ST.xy + _DiffuseTex_ST.zw;
			float4 tex2DNode54 = tex2D( _DiffuseTex, uv_DiffuseTex );
			float3 desaturateInitialColor128 = tex2DNode54.rgb;
			float desaturateDot128 = dot( desaturateInitialColor128, float3( 0.299, 0.587, 0.114 ));
			float3 desaturateVar128 = lerp( desaturateInitialColor128, desaturateDot128.xxx, _ShadowDetail );
			float4 blendOpSrc135 = _ShadowCol;
			float4 blendOpDest135 = float4( desaturateVar128 , 0.0 );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float fresnelNdotV16 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode16 = ( _BiasVal + _ScaleVal * pow( 1.0 - fresnelNdotV16, _PowerVal ) );
			float3 temp_output_60_0 = mul( unity_WorldToObject, float4( ase_worldNormal , 0.0 ) ).xyz;
			float dotResult63 = dot( abs( temp_output_60_0 ) , float3(1,1,1) );
			float3 BlendComponents65 = ( temp_output_60_0 / dotResult63 );
			float lerpResult67 = lerp( 0.0 , fresnelNode16 , BlendComponents65.y);
			float4 temp_output_20_0 = ( lerpResult67 * _FresnelCol );
			half3 NORMAL99_g5 = (WorldNormalVector( i , half3(0,0,1) ));
			float3 normalizeResult73_g5 = normalize( NORMAL99_g5 );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 normalizeResult40_g5 = normalize( ( ase_worldViewDir + ase_worldlightDir ) );
			float dotResult45_g5 = dot( normalizeResult73_g5 , normalizeResult40_g5 );
			float4 temp_output_81_12 = ( pow( max( dotResult45_g5 , 0.0 ) , ( 128.0 * max( _Shininess , 0.01 ) ) ) * _SpecularColor );
			float2 uv_SpecularMaskTex = i.uv_texcoord * _SpecularMaskTex_ST.xy + _SpecularMaskTex_ST.zw;
			float4 lerpResult86 = lerp( temp_output_81_12 , float4( 0,0,0,0 ) , tex2D( _SpecularMaskTex, uv_SpecularMaskTex ).r);
			float dotResult5_g4 = dot( ase_worldNormal , ase_worldlightDir );
			float4 appendResult73 = (float4((dotResult5_g4*0.5 + 0.5) , _XToonVal , 0.0 , 0.0));
			float4 blendOpSrc136 = temp_output_20_0;
			float4 blendOpDest136 = ( lerpResult86 + ( tex2DNode54 * tex2D( _ToonRampTex, appendResult73.xy ) ) );
			float2 uv_LightTex = i.uv_texcoord * _LightTex_ST.xy + _LightTex_ST.zw;
			float2 uv_NormalsTex = i.uv_texcoord * _NormalsTex_ST.xy + _NormalsTex_ST.zw;
			float dotResult41 = dot( normalize( (WorldNormalVector( i , UnpackNormal( tex2D( _NormalsTex, uv_NormalsTex ) ) )) ) , ase_worldlightDir );
			float clampResult50 = clamp( ( ( dotResult41 + _ShadowOffset ) * _ShadowSharpness ) , 0.0 , 1.0 );
			float clampResult52 = clamp( ( ase_lightAtten * clampResult50 ) , 0.0 , 1.0 );
			float4 lerpResult3 = lerp( ( saturate( ( blendOpSrc135 * blendOpDest135 ) )) , ( saturate( 	max( blendOpSrc136, blendOpDest136 ) )) , ( tex2D( _LightTex, uv_LightTex ) * clampResult52 ));
			float3 temp_output_117_0 = abs( ase_worldNormal );
			float clampResult122 = clamp( ( ase_worldNormal * temp_output_117_0 ).y , 0.0 , 1.0 );
			float4 lerpResult108 = lerp( float4( 0,0,0,0 ) , _SkyBounceCol , clampResult122);
			float clampResult123 = clamp( ( -ase_worldNormal * temp_output_117_0 ).y , 0.0 , 1.0 );
			float4 lerpResult110 = lerp( float4( 0,0,0,0 ) , _GroundBounceCol , clampResult123);
			float4 lerpResult138 = lerp( ( lerpResult108 + lerpResult110 ) , _NightBounceCol , NightTransitionMaterial);
			c.rgb = ( lerpResult142 * ( lerpResult3 + lerpResult138 ) ).rgb;
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
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
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
				surfIN.uv_texcoord = IN.customPack1.xy;
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
0;376.8;1731;715;3299.912;1798.511;3.239911;True;True
Node;AmplifyShaderEditor.CommentaryNode;72;-3216.576,-259.387;Float;False;1975.473;706.6298;Comment;16;63;58;64;62;60;61;65;59;66;67;20;16;70;71;69;19;Vertical Rim Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;33;-4064.121,599.3315;Float;False;831.9146;313.1678;Comment;1;35;Normals;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldToObjectMatrix;58;-3166.576,-209.387;Float;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.WorldNormalVector;59;-3166.576,-113.3871;Float;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;36;-3193.767,594.2704;Float;False;836.6255;384.7068;Comment;3;41;40;39;WorldDotLight;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-2894.576,-145.3869;Float;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;35;-3756.317,647.8245;Float;True;Property;_NormalsTex;NormalsTex;10;0;Create;True;0;0;False;0;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;39;-2990.836,809.2463;Float;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.AbsOpNode;62;-2715.006,-42.19478;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;43;-2319.085,593.5505;Float;False;1082.442;371.774;Shadowmask (no color);8;52;51;50;49;48;47;46;44;Light / ShadowMask;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;125;-3164.712,-1001.012;Float;False;1927.987;640.3427;Comment;14;117;120;119;116;102;88;122;123;108;99;105;110;124;115;Sky / Ground Bounce Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;40;-2978.344,651.9944;Float;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;61;-2907.579,-2.537479;Float;False;Constant;_Vector0;Vector 0;-1;0;Create;True;0;0;False;0;1,1,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;115;-3114.712,-849.2207;Float;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;44;-2263.329,759.4694;Float;False;Property;_ShadowOffset;ShadowOffset;7;0;Create;True;0;0;False;0;0;-0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;63;-2555.34,-45.18486;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;41;-2727.193,748.0204;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;78;-2178.744,2206.229;Float;False;887.0688;280;Comment;4;73;55;53;74;xToon Tamp;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;74;-2128.744,2347.857;Float;False;Property;_XToonVal;XToonVal;20;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;120;-2870.475,-675.3224;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-2269.083,850.3243;Float;False;Property;_ShadowSharpness;ShadowSharpness;9;0;Create;True;0;0;False;0;0;14.55;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;46;-2043.525,701.9003;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;53;-2118.255,2261.543;Float;False;Half Lambert Term;-1;;4;86299dc21373a954aa5772333626c9c1;0;1;3;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;117;-2864.144,-762.7194;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;64;-2398.576,-145.3869;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;126;-1983.088,1448.857;Float;False;711.775;387.9122;Comment;3;87;81;86;Specular;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-3141.715,136.8129;Float;False;Property;_BiasVal;BiasVal;14;0;Create;True;0;0;False;0;0;0.08;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-3146.685,332.2428;Float;False;Property;_PowerVal;PowerVal;13;0;Create;True;0;0;False;0;0;6.09;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;65;-2238.576,-145.3869;Float;True;BlendComponents;1;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;70;-3145.028,237.8402;Float;False;Property;_ScaleVal;ScaleVal;15;0;Create;True;0;0;False;0;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;73;-1808.247,2262.509;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;-1909.363,723.7723;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;119;-2682.649,-693.6603;Float;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;116;-2683.15,-943.727;Float;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;55;-1608.673,2256.229;Float;True;Property;_ToonRampTex;ToonRampTex;12;0;Create;True;0;0;False;0;None;52e66a9243cdfed44b5e906f5910d35b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LightAttenuation;49;-1896.427,637.7505;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;87;-1933.088,1606.769;Float;True;Property;_SpecularMaskTex;SpecularMaskTex;16;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;50;-1760.871,793.7422;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;54;-1566.132,1931.03;Float;True;Property;_DiffuseTex;DiffuseTex;11;0;Create;True;0;0;False;0;None;9277315cb90c643408c990ad4273efdf;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;81;-1840.532,1508.725;Float;False;Lighting Specular;0;;5;503457513f257784c866265a383a60d7;1,103,2;2;100;FLOAT3;0,0,0;False;102;FLOAT3;0,0,0;False;1;COLOR;12
Node;AmplifyShaderEditor.FresnelNode;16;-2757.436,171.0456;Float;False;Standard;WorldNormal;ViewDir;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;102;-2447.431,-690.437;Float;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.BreakToComponentsNode;88;-2457.026,-940.5065;Float;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.BreakToComponentsNode;66;-2008.007,-143.7431;Float;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.LerpOp;86;-1449.792,1501.618;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;67;-1747.431,-149.6938;Float;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;99;-2055.022,-809.0625;Float;False;Property;_SkyBounceCol;SkyBounceCol;6;0;Create;True;0;0;False;0;0,0,0,0;0.2641509,0.1532573,0.1649303,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;133;-984.7996,1689.786;Float;False;Property;_ShadowDetail;ShadowDetail;17;0;Create;True;0;0;False;0;0;0.201;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;-907.41,2082.363;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-1587.208,761.1104;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;19;-2383.732,173.6089;Float;False;Property;_FresnelCol;FresnelCol;4;0;Create;True;0;0;False;0;0,0,0,0;0.8679245,0.789219,0.6836953,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;123;-2190.211,-695.0883;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;122;-2203.513,-937.3276;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;105;-2058.018,-567.6694;Float;False;Property;_GroundBounceCol;GroundBounceCol;5;0;Create;True;0;0;False;0;0,0,0,0;0.08222844,0.04058341,0.1509428,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;82;-685.5237,392.5639;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-1476.105,-155.69;Float;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;21;-1517.725,990.514;Float;True;Property;_LightTex;LightTex;8;0;Create;True;0;0;False;0;None;2bcd3702f4f47421e943dac22642d8c6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DesaturateOpNode;128;-994.6897,1455.979;Float;True;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClampOpNode;52;-1416.328,765.6783;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;2;-825.6456,1250.387;Float;False;Property;_ShadowCol;ShadowCol;3;0;Create;True;0;0;False;0;0,0,0,0;0.125944,0.03355287,0.2452828,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;108;-1750.213,-951.012;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;110;-1737.917,-674.6088;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;139;-1368.91,-1338.554;Float;False;Property;_NightBounceCol;NightBounceCol;19;0;Create;True;0;0;False;0;0.1501615,0,0.9339623,0;0.1501615,0,0.9339623,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;124;-1471.725,-824.1941;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;137;-2031.596,-1380.456;Float;False;Global;NightTransitionMaterial;NightTransitionMaterial;17;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;136;-519.8056,147.0283;Float;True;Lighten;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;85;-1030.529,822.3405;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendOpsNode;135;-317.4478,1584.154;Float;False;Multiply;True;3;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;3;315.333,712.167;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;138;-349.3782,-753.1337;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;141;-1410.919,-1580.657;Float;False;Property;_NightCol;NightCol;18;0;Create;True;0;0;False;0;0.1501615,0,0.9339623,0;0.1501615,0,0.9339623,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;142;-393.7123,-1487.48;Float;True;3;0;COLOR;1,1,1,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;118;695.4707,78.72247;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;127;-1666.186,1176.629;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;140;826.8209,-366.6891;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1248.278,-460.8777;Float;False;True;2;Float;ASEMaterialInspector;0;0;CustomLighting;Wood;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;60;0;58;0
WireConnection;60;1;59;0
WireConnection;62;0;60;0
WireConnection;40;0;35;0
WireConnection;63;0;62;0
WireConnection;63;1;61;0
WireConnection;41;0;40;0
WireConnection;41;1;39;0
WireConnection;120;0;115;0
WireConnection;46;0;41;0
WireConnection;46;1;44;0
WireConnection;117;0;115;0
WireConnection;64;0;60;0
WireConnection;64;1;63;0
WireConnection;65;0;64;0
WireConnection;73;0;53;0
WireConnection;73;1;74;0
WireConnection;48;0;46;0
WireConnection;48;1;47;0
WireConnection;119;0;120;0
WireConnection;119;1;117;0
WireConnection;116;0;115;0
WireConnection;116;1;117;0
WireConnection;55;1;73;0
WireConnection;50;0;48;0
WireConnection;16;1;69;0
WireConnection;16;2;70;0
WireConnection;16;3;71;0
WireConnection;102;0;119;0
WireConnection;88;0;116;0
WireConnection;66;0;65;0
WireConnection;86;0;81;12
WireConnection;86;2;87;1
WireConnection;67;1;16;0
WireConnection;67;2;66;1
WireConnection;56;0;54;0
WireConnection;56;1;55;0
WireConnection;51;0;49;0
WireConnection;51;1;50;0
WireConnection;123;0;102;1
WireConnection;122;0;88;1
WireConnection;82;0;86;0
WireConnection;82;1;56;0
WireConnection;20;0;67;0
WireConnection;20;1;19;0
WireConnection;128;0;54;0
WireConnection;128;1;133;0
WireConnection;52;0;51;0
WireConnection;108;1;99;0
WireConnection;108;2;122;0
WireConnection;110;1;105;0
WireConnection;110;2;123;0
WireConnection;124;0;108;0
WireConnection;124;1;110;0
WireConnection;136;0;20;0
WireConnection;136;1;82;0
WireConnection;85;0;21;0
WireConnection;85;1;52;0
WireConnection;135;0;2;0
WireConnection;135;1;128;0
WireConnection;3;0;135;0
WireConnection;3;1;136;0
WireConnection;3;2;85;0
WireConnection;138;0;124;0
WireConnection;138;1;139;0
WireConnection;138;2;137;0
WireConnection;142;1;141;0
WireConnection;142;2;137;0
WireConnection;118;0;3;0
WireConnection;118;1;138;0
WireConnection;127;0;20;0
WireConnection;127;1;81;12
WireConnection;140;0;142;0
WireConnection;140;1;118;0
WireConnection;0;13;140;0
ASEEND*/
//CHKSM=271982FDE7C4874BACE380806FF5D94DE7E753A6