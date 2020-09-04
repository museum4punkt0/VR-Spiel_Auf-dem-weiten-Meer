// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SeaShell"
{
	Properties
	{
		_Color1("Color 1", Color) = (0,0,0,0)
		_MainColor("Main Color", Color) = (0.3921569,0.3921569,0.3921569,1)
		_SpecularColor("Specular Color", Color) = (0.3921569,0.3921569,0.3921569,1)
		_Shininess("Shininess", Range( 0.01 , 1)) = 0.1
		_LightCol("LightCol", Color) = (0,0,0,0)
		_Color0("Color 0", Color) = (0,0,0,0)
		_ShadowCol("ShadowCol", Color) = (0,0,0,0)
		_ShadowOffset("ShadowOffset", Float) = 0
		_ShadowSharpness("ShadowSharpness", Float) = 0
		_AOtex("AOtex", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
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
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
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

		uniform float4 _SpecularColor;
		uniform float _Shininess;
		uniform float4 _MainColor;
		uniform float4 _ShadowCol;
		uniform float4 _LightCol;
		uniform float _ShadowOffset;
		uniform float _ShadowSharpness;
		uniform float4 _Color0;
		uniform float4 _Color1;
		uniform float NightTransitionMaterial;
		uniform sampler2D _AOtex;
		uniform float4 _AOtex_ST;

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
			float4 temp_output_43_0_g1 = _SpecularColor;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 normalizeResult4_g2 = normalize( ( ase_worldViewDir + ase_worldlightDir ) );
			float3 normalizeResult64_g1 = normalize( (WorldNormalVector( i , float3(0,0,1) )) );
			float dotResult19_g1 = dot( normalizeResult4_g2 , normalizeResult64_g1 );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 temp_output_40_0_g1 = ( ase_lightColor * ase_lightAtten );
			float dotResult14_g1 = dot( normalizeResult64_g1 , ase_worldlightDir );
			UnityGI gi34_g1 = gi;
			float3 diffNorm34_g1 = normalizeResult64_g1;
			gi34_g1 = UnityGI_Base( data, 1, diffNorm34_g1 );
			float3 indirectDiffuse34_g1 = gi34_g1.indirect.diffuse + diffNorm34_g1 * 0.0001;
			float4 temp_output_42_0_g1 = _MainColor;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float dotResult3 = dot( ase_worldNormal , ase_worldlightDir );
			float clampResult8 = clamp( ( ( dotResult3 + _ShadowOffset ) * _ShadowSharpness ) , 0.0 , 1.0 );
			float clampResult15 = clamp( ( 0.0 * clampResult8 ) , 0.0 , 1.0 );
			float4 lerpResult26 = lerp( _ShadowCol , _LightCol , clampResult15);
			float4 lerpResult19 = lerp( _Color0 , _Color1 , clampResult15);
			float4 lerpResult23 = lerp( lerpResult26 , lerpResult19 , NightTransitionMaterial);
			float2 uv_AOtex = i.uv_texcoord * _AOtex_ST.xy + _AOtex_ST.zw;
			float4 tex2DNode30 = tex2D( _AOtex, uv_AOtex );
			c.rgb = ( ( ( ( float4( (temp_output_43_0_g1).rgb , 0.0 ) * (temp_output_43_0_g1).a * pow( max( dotResult19_g1 , 0.0 ) , ( _Shininess * 128.0 ) ) * temp_output_40_0_g1 ) + ( ( ( temp_output_40_0_g1 * max( dotResult14_g1 , 0.0 ) ) + float4( indirectDiffuse34_g1 , 0.0 ) ) * float4( (temp_output_42_0_g1).rgb , 0.0 ) ) ) + lerpResult23 ) * tex2DNode30 ).rgb;
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
Version=17700
348;694;1440;732;1158.51;1453.237;2.734406;True;True
Node;AmplifyShaderEditor.WorldNormalVector;2;-1412.927,116.8077;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;1;-1377.132,319.846;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;4;-795.751,294.049;Float;False;Property;_ShadowOffset;ShadowOffset;9;0;Create;True;0;0;False;0;0;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;3;-906.8962,231.3803;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-801.506,384.9041;Float;False;Property;_ShadowSharpness;ShadowSharpness;11;0;Create;True;0;0;False;0;0;1.99;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;5;-575.9495,236.4801;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-441.7863,258.3521;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;8;-293.295,328.3222;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-119.631,295.6901;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;25;-21.58228,-451.3493;Float;False;Property;_LightCol;LightCol;5;0;Create;True;0;0;False;0;0,0,0,0;0.6037736,0.5610537,0.5610537,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;24;-74.72894,-628.2828;Float;False;Property;_ShadowCol;ShadowCol;7;0;Create;True;0;0;False;0;0,0,0,0;0.4716981,0.1989777,0.1045745,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;15;51.24701,300.2581;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;17;-153.3787,-210.4336;Float;False;Property;_Color0;Color 0;6;0;Create;True;0;0;False;0;0,0,0,0;0.6603774,0.4808031,0.4205233,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;16;-153.2867,-19.35271;Float;False;Property;_Color1;Color 1;0;0;Create;True;0;0;False;0;0,0,0,0;0.9716981,0.6004361,0.6004361,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;26;619.2033,-451.7161;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;19;637.6973,-134.4837;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-403.5749,-1552.198;Inherit;False;Global;NightTransitionMaterial;NightTransitionMaterial;8;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;27;343.0534,-1529.203;Inherit;False;Blinn-Phong Light;1;;1;cf814dba44d007a4e958d2ddd5813da6;0;3;42;COLOR;0,0,0,0;False;52;FLOAT3;0,0,0;False;43;COLOR;0,0,0,0;False;2;COLOR;0;FLOAT;57
Node;AmplifyShaderEditor.LerpOp;23;1351.969,-287.3982;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;28;1269.766,-1241.576;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;30;587.2255,291.9542;Inherit;True;Property;_AOtex;AOtex;13;0;Create;True;0;0;False;0;-1;None;51f0f1e38636442089be4a9c0a3ba117;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;13;-1265.877,-349.7396;Float;False;Property;_FresnelPower;FresnelPower;15;0;Create;True;0;0;False;0;0.73;0.73;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;1162.443,118.1835;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;1080.108,-247.9361;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendOpsNode;21;1064.57,-703.0121;Inherit;False;Lighten;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-1274.408,-475.5625;Float;False;Property;_FresnelScale;FresnelScale;14;0;Create;True;0;0;False;0;0.52;0.52;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;14;-868.2126,-915.3608;Inherit;False;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-503.4159,-864.3567;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;18;-849.9896,-720.3126;Float;False;Property;_FresnelCol;FresnelCol;8;0;Create;True;0;0;False;0;0.990566,0.5747152,0.5747152,0;0.990566,0.5747152,0.5747152,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;29;847.7271,-996.595;Inherit;True;Property;_TextureSample0;Texture Sample 0;12;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;1578.631,-1073.155;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-1285.071,-607.7832;Float;False;Property;_FresnelBias;FresnelBias;10;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;9;-1463.596,-920.0646;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1795.349,-923.7131;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;SeaShell;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;3;0;2;0
WireConnection;3;1;1;0
WireConnection;5;0;3;0
WireConnection;5;1;4;0
WireConnection;7;0;5;0
WireConnection;7;1;6;0
WireConnection;8;0;7;0
WireConnection;12;1;8;0
WireConnection;15;0;12;0
WireConnection;26;0;24;0
WireConnection;26;1;25;0
WireConnection;26;2;15;0
WireConnection;19;0;17;0
WireConnection;19;1;16;0
WireConnection;19;2;15;0
WireConnection;23;0;26;0
WireConnection;23;1;19;0
WireConnection;23;2;22;0
WireConnection;28;0;27;0
WireConnection;28;1;23;0
WireConnection;31;0;19;0
WireConnection;31;1;30;0
WireConnection;32;0;26;0
WireConnection;32;1;30;0
WireConnection;21;0;20;0
WireConnection;21;1;23;0
WireConnection;14;0;9;0
WireConnection;14;1;10;0
WireConnection;14;2;11;0
WireConnection;14;3;13;0
WireConnection;20;0;14;0
WireConnection;20;1;18;0
WireConnection;33;0;28;0
WireConnection;33;1;30;0
WireConnection;0;13;33;0
ASEEND*/
//CHKSM=1A63F554FFA3AE14DC51AB5F79A209BBC5FA79B6