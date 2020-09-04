// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TriPlanarCloud"
{
	Properties
	{
		_TilingNoise("TilingNoise", Vector) = (0,0.2,0,0)
		_AlbedoCol("AlbedoCol", Color) = (0,0,0,0)
		_AlbedoCol2("AlbedoCol2", Color) = (0,0,0,0)
		_Matcap("Matcap", 2D) = "white" {}
		_Falloff("Falloff", Range( 0 , 1)) = 0.5
		_Cutoff( "Mask Clip Value", Float ) = -6
		_Noise("Noise", 2D) = "white" {}
		_FresnelPowerInner("FresnelPowerInner", Float) = 0
		_FresnelPowerOuter("FresnelPowerOuter", Float) = 0
		_OffsetPower("OffsetPower", Float) = 0
		_StartPoint("StartPoint", Float) = 0
		_Distribution("Distribution", Float) = 0
		[Toggle]_FadeClouds("FadeClouds", Float) = 0
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Transparent+0" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha , Zero Zero
		
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
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

		uniform sampler2D _Noise;
		uniform float2 _TilingNoise;
		uniform float _OffsetPower;
		uniform sampler2D _Matcap;
		uniform float _Falloff;
		uniform float4 _AlbedoCol2;
		uniform float4 _AlbedoCol;
		uniform float _StartPoint;
		uniform float _Distribution;
		uniform float _FadeClouds;
		uniform float _FresnelPowerInner;
		uniform float _FresnelPowerOuter;
		uniform float gCloudsAlpha;
		uniform float _Cutoff = -6;


		inline float4 TriplanarSamplingSV( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
		{
			float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
			projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
			float3 nsign = sign( worldNormal );
			half4 xNorm; half4 yNorm; half4 zNorm;
			xNorm = ( tex2Dlod( ASE_TEXTURE_PARAMS( topTexMap ), float4( tiling * worldPos.zy * float2( nsign.x, 1.0 ), 0, 0 ) ) );
			yNorm = ( tex2Dlod( ASE_TEXTURE_PARAMS( topTexMap ), float4( tiling * worldPos.xz * float2( nsign.y, 1.0 ), 0, 0 ) ) );
			zNorm = ( tex2Dlod( ASE_TEXTURE_PARAMS( topTexMap ), float4( tiling * worldPos.xy * float2( -nsign.z, 1.0 ), 0, 0 ) ) );
			return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
		}


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


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float3 ase_worldNormal = UnityObjectToWorldNormal( v.normal );
			float4 triplanar1 = TriplanarSamplingSV( _Noise, ase_worldPos, ase_worldNormal, 1.0, _TilingNoise, 1.0, 0 );
			float3 ase_vertexNormal = v.normal.xyz;
			v.vertex.xyz += ( triplanar1 * float4( ase_vertexNormal , 0.0 ) * _OffsetPower ).xyz;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float4 triplanar1 = TriplanarSamplingSF( _Noise, ase_worldPos, ase_worldNormal, 1.0, _TilingNoise, 1.0, 0 );
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float fresnelNdotV3 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode3 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV3, _FresnelPowerInner ) );
			float fresnelNdotV8 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode8 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV8, _FresnelPowerOuter ) );
			float temp_output_15_0 = ( saturate( (0.0 + (( triplanar1.x + ( 1.0 - fresnelNode3 ) ) - 0.0) * (1.0 - 0.0) / (1.0 - 0.0)) ) * (0.0 + (( 1.0 - fresnelNode8 ) - 0.0) * (1.0 - 0.0) / (1.0 - 0.0)) );
			c.rgb = 0;
			c.a = (( _FadeClouds )?( 0.0 ):( ( saturate( temp_output_15_0 ) * gCloudsAlpha ) ));
			clip( temp_output_15_0 - _Cutoff );
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
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult79 = dot( ase_worldNormal , ase_worldViewDir );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult5_g279 = dot( ase_worldNormal , ase_worldlightDir );
			float4 appendResult78 = (float4(( dotResult79 * _Falloff ) , (dotResult5_g279*0.5 + 0.5) , 0.0 , 0.0));
			float4 lerpResult44 = lerp( _AlbedoCol2 , _AlbedoCol , saturate( ( ( ase_worldPos.y + _StartPoint ) / _Distribution ) ));
			float4 blendOpSrc81 = tex2D( _Matcap, appendResult78.xy );
			float4 blendOpDest81 = lerpResult44;
			o.Emission = ( saturate( 2.0f*blendOpDest81*blendOpSrc81 + blendOpDest81*blendOpDest81*(1.0f - 2.0f*blendOpSrc81) )).rgb;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows exclude_path:deferred nofog vertex:vertexDataFunc 

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
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float4 tSpace0 : TEXCOORD1;
				float4 tSpace1 : TEXCOORD2;
				float4 tSpace2 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
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
				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT( UnityGI, gi );
				o.Alpha = LightingStandardCustomLighting( o, worldViewDir, gi ).a;
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17700
0;0;2560;1379;63.12356;1005.889;1.652687;True;True
Node;AmplifyShaderEditor.RangedFloatNode;6;175.6365,612.8738;Float;False;Property;_FresnelPowerInner;FresnelPowerInner;14;0;Create;True;0;0;False;0;0;1.23;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;7;-62.99968,419.5681;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector2Node;25;-810.9421,664.4301;Float;False;Property;_TilingNoise;TilingNoise;1;0;Create;True;0;0;False;0;0,0.2;0.00025,0.00025;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.FresnelNode;3;354.6365,335.8738;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.TriplanarNode;1;-230.5031,643.0535;Inherit;True;Spherical;World;False;Noise;_Noise;white;13;Assets/AmplifyShaderEditor/Examples/Community/Dissolve Burn/dissolve-guide.png;Mid Texture 0;_MidTexture0;white;-1;None;Bot Texture 0;_BotTexture0;white;-1;None;Triplanar Sampler;False;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;10;421.9698,718.5405;Float;False;Property;_FresnelPowerOuter;FresnelPowerOuter;15;0;Create;True;0;0;False;0;0;0.51;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;5;602.6365,333.8738;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;4;744.6365,218.8738;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;8;581.7223,518.5306;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;58;373.2964,-337.3987;Float;False;Property;_StartPoint;StartPoint;17;0;Create;True;0;0;False;0;0;-1485.39;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;74;2113.288,-521.5287;Float;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;63;-13.19853,-410.7538;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.OneMinusNode;11;846.6365,496.8738;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;12;988.5996,652.1807;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;73;2147.644,-707.3647;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;14;1259.61,267.5848;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;13;934.3302,598.7642;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;79;2523.574,-412.6041;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;61;413.8235,-232.028;Float;False;Property;_Distribution;Distribution;19;0;Create;True;0;0;False;0;0;-300;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;75;2504.737,-756.4587;Float;False;Property;_Falloff;Falloff;11;0;Create;True;0;0;False;0;0.5;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;57;561.8002,-511.6651;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;59;778.5671,-556.2446;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;76;1806.951,-792.942;Inherit;False;Half Lambert Term;-1;;279;86299dc21373a954aa5772333626c9c1;0;1;3;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;2775.077,-316.1987;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;1389.954,430.0465;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;45;1082.095,-621.4731;Float;False;Property;_AlbedoCol2;AlbedoCol2;5;0;Create;True;0;0;False;0;0,0,0,0;0.9528301,0.9528301,0.9528301,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;60;780.2615,-281.3858;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;16;2494.713,261.3325;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;78;3068.686,-375.4667;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;84;2102.238,1193.623;Float;False;Global;gCloudsAlpha;gCloudsAlpha;23;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;29;1086.38,-275.753;Float;False;Property;_AlbedoCol;AlbedoCol;3;0;Create;True;0;0;False;0;0,0,0,0;0.6297169,0.7917675,0.8396226,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;2730.999,210.2166;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;80;2793.409,-208.262;Inherit;True;Property;_Matcap;Matcap;9;0;Create;True;0;0;False;0;-1;None;41eac93c5ee3144ccb92d4dbbdadb1ba;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;19;724.5602,1158.581;Float;False;Property;_OffsetPower;OffsetPower;16;0;Create;True;0;0;False;0;0;0.97;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;18;474.5791,1043.458;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;44;2031.014,-232.3347;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;64;807.2717,-1026.094;Float;False;Property;_StartPointB;StartPointB;18;0;Create;True;0;0;False;0;0;-703.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;31;-629.6928,432.3503;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;54;1420.977,118.206;Float;False;Property;_NormalIntensity;NormalIntensity;10;0;Create;True;0;0;False;0;0;0.32;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;81;3160.802,19.95485;Inherit;False;SoftLight;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;71;1559.08,-941.5117;Float;False;Property;_Color4;Color 4;6;0;Create;True;0;0;False;0;0,0,0,0;1,0.9009434,0.962967,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;67;1038.786,-831.7037;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-1472.287,496.13;Float;False;Property;_NoiseSpeed;NoiseSpeed;7;0;Create;True;0;0;False;0;0;0.004;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;1882.866,147.3441;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;1934.02,-7.257446;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;28;34.52271,64.05791;Float;False;Property;_TilingNormal;TilingNormal;2;0;Create;True;0;0;False;0;0,0.2;0.001,0.001;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SaturateNode;69;1257.247,-601.4244;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;55;2169.682,25.00696;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;867.6415,969.4507;Inherit;False;3;3;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ColorNode;70;1487.003,-735.9768;Float;False;Property;_Color3;Color 3;4;0;Create;True;0;0;False;0;0,0,0,0;0.4643111,0.6589629,0.8867924,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;34;-1106.915,369.3336;Float;False;Property;_NoiseDIr;NoiseDIr;8;0;Create;True;0;0;False;0;0,0;0.002,0.02;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.LerpOp;72;1877.086,-711.6949;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TriplanarNode;27;579.4022,-1.684839;Inherit;True;Spherical;World;False;Normal;_Normal;white;0;None;Mid Texture 1;_MidTexture1;white;-1;None;Bot Texture 1;_BotTexture1;white;-1;None;Triplanar Sampler;False;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;56;2341.507,70.98782;Inherit;False;FLOAT3;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleTimeNode;33;-1423.818,245.4854;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;65;363.7015,-949.7523;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ToggleSwitchNode;85;2650.745,1134.27;Float;False;Property;_FadeClouds;FadeClouds;21;0;Create;True;0;0;False;0;0;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;68;1255.552,-876.2833;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;66;972.7325,-1045.658;Float;False;Property;_DistributionB;DistributionB;20;0;Create;True;0;0;False;0;0;-263.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;3423.737,119.9416;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;TriPlanarCloud;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;-6;True;True;0;True;TransparentCutout;;Transparent;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;12;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;3;4;7;0
WireConnection;3;3;6;0
WireConnection;1;3;25;0
WireConnection;5;0;3;0
WireConnection;4;0;1;1
WireConnection;4;1;5;0
WireConnection;8;4;7;0
WireConnection;8;3;10;0
WireConnection;11;0;8;0
WireConnection;12;0;4;0
WireConnection;14;0;12;0
WireConnection;13;0;11;0
WireConnection;79;0;73;0
WireConnection;79;1;74;0
WireConnection;57;0;63;2
WireConnection;57;1;58;0
WireConnection;59;0;57;0
WireConnection;59;1;61;0
WireConnection;77;0;79;0
WireConnection;77;1;75;0
WireConnection;15;0;14;0
WireConnection;15;1;13;0
WireConnection;60;0;59;0
WireConnection;16;0;15;0
WireConnection;78;0;77;0
WireConnection;78;1;76;0
WireConnection;82;0;16;0
WireConnection;82;1;84;0
WireConnection;80;1;78;0
WireConnection;44;0;45;0
WireConnection;44;1;29;0
WireConnection;44;2;60;0
WireConnection;31;0;25;0
WireConnection;31;2;34;0
WireConnection;31;1;33;0
WireConnection;81;0;80;0
WireConnection;81;1;44;0
WireConnection;67;0;65;2
WireConnection;67;1;64;0
WireConnection;53;0;27;2
WireConnection;53;1;54;0
WireConnection;52;0;27;1
WireConnection;52;1;54;0
WireConnection;69;0;68;0
WireConnection;55;0;52;0
WireConnection;55;1;53;0
WireConnection;17;0;1;0
WireConnection;17;1;18;0
WireConnection;17;2;19;0
WireConnection;72;0;71;0
WireConnection;72;1;70;0
WireConnection;72;2;69;0
WireConnection;27;3;28;0
WireConnection;56;0;55;0
WireConnection;56;2;27;3
WireConnection;33;0;32;0
WireConnection;85;0;82;0
WireConnection;68;0;67;0
WireConnection;68;1;66;0
WireConnection;0;2;81;0
WireConnection;0;9;85;0
WireConnection;0;10;15;0
WireConnection;0;11;17;0
ASEEND*/
//CHKSM=288E4086BADB39B086FAF96FE2B77704DBDE7B31