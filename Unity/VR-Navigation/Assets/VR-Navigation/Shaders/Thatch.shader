// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Thatch"
{
	Properties
	{
		_ShadowOffset("ShadowOffset", Float) = 0
		_ShadowSharpness("ShadowSharpness", Float) = 0
		_Normals("Normals", 2D) = "bump" {}
		_NormalScale("Normal Scale", Range( -1 , 1)) = 0
		_LightCol("LightCol", Color) = (0,0,0,0)
		_NightLightCol("NightLightCol", Color) = (0,0,0,0)
		_ShadowCol("ShadowCol", Color) = (0,0,0,0)
		_NightShadowCol("NightShadowCol", Color) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityStandardUtils.cginc"
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
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
			float3 worldPos;
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

		uniform float4 _ShadowCol;
		uniform float4 _LightCol;
		uniform float _NormalScale;
		uniform sampler2D _Normals;
		uniform float4 _Normals_ST;
		uniform float _ShadowOffset;
		uniform float _ShadowSharpness;
		uniform float4 _NightShadowCol;
		uniform float4 _NightLightCol;
		uniform float NightTransitionMaterial;

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
			float2 uv_Normals = i.uv_texcoord * _Normals_ST.xy + _Normals_ST.zw;
			float3 Normals95 = UnpackScaleNormal( tex2D( _Normals, uv_Normals ), _NormalScale );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult4 = dot( normalize( (WorldNormalVector( i , Normals95 )) ) , ase_worldlightDir );
			float WorldDotLight6 = dotResult4;
			float clampResult24 = clamp( ( ( WorldDotLight6 + _ShadowOffset ) * _ShadowSharpness ) , 0.0 , 1.0 );
			float clampResult38 = clamp( ( ase_lightAtten * clampResult24 ) , 0.0 , 1.0 );
			float4 lerpResult102 = lerp( _ShadowCol , _LightCol , clampResult38);
			float4 lerpResult108 = lerp( _NightShadowCol , _NightLightCol , float4( 0,0,0,0 ));
			float4 lerpResult107 = lerp( lerpResult102 , lerpResult108 , NightTransitionMaterial);
			c.rgb = lerpResult107.rgb;
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
210.4;350.4;1731;715;48.24989;2660.432;2.383338;True;True
Node;AmplifyShaderEditor.CommentaryNode;99;-2325.871,-1413.903;Float;False;831.9146;313.1678;Comment;3;100;95;94;Normals;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;100;-2284.085,-1311.967;Float;False;Property;_NormalScale;Normal Scale;3;0;Create;True;0;0;False;0;0;-1;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;94;-2018.067,-1365.41;Float;True;Property;_Normals;Normals;2;0;Create;True;0;0;False;0;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;1;-1478.417,-1418.964;Float;False;836.6255;384.7068;Comment;5;96;2;6;4;3;WorldDotLight;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;95;-1705.295,-1361.794;Float;False;Normals;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;96;-1452.424,-1360.126;Float;False;95;Normals;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;3;-1275.485,-1203.988;Float;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;2;-1262.993,-1361.24;Float;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;4;-1011.842,-1265.214;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;5;317.9308,-1420.479;Float;False;1082.442;371.774;Shadowmask (no color);9;38;25;24;18;16;12;10;8;88;Toon-ify lights/shadows;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;6;-818.3795,-1279.258;Float;False;WorldDotLight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;373.6869,-1254.561;Float;False;Property;_ShadowOffset;ShadowOffset;0;0;Create;True;0;0;False;0;0;-0.21;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;10;372.7949,-1354.2;Float;False;6;WorldDotLight;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;16;593.4885,-1312.13;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;367.9319,-1163.706;Float;False;Property;_ShadowSharpness;ShadowSharpness;1;0;Create;True;0;0;False;0;0;56.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;727.6516,-1290.258;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;24;876.143,-1220.288;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;88;740.5883,-1376.279;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;1049.807,-1252.92;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;103;1502.828,-1780.434;Float;False;Property;_LightCol;LightCol;4;0;Create;True;0;0;False;0;0,0,0,0;1,0.5235849,0.5235849,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;38;1220.685,-1248.352;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;104;1745.478,-1836.602;Float;False;Property;_ShadowCol;ShadowCol;6;0;Create;True;0;0;False;0;0,0,0,0;0.320727,0.06065327,0.4433962,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;109;1667.314,-2365.501;Float;False;Property;_NightLightCol;NightLightCol;5;0;Create;True;0;0;False;0;0,0,0,0;1,0.5235849,0.5235849,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;110;1909.964,-2421.669;Float;False;Property;_NightShadowCol;NightShadowCol;7;0;Create;True;0;0;False;0;0,0,0,0;0.320727,0.06065327,0.4433962,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;106;1236.369,-2026.464;Float;False;Global;NightTransitionMaterial;NightTransitionMaterial;6;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;102;1904.998,-1558.005;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;108;2069.484,-2143.072;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;107;2363.688,-1907.297;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;1,1,1,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2690.223,-1161.034;Float;False;True;2;Float;ASEMaterialInspector;0;0;CustomLighting;Thatch;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;94;5;100;0
WireConnection;95;0;94;0
WireConnection;2;0;96;0
WireConnection;4;0;2;0
WireConnection;4;1;3;0
WireConnection;6;0;4;0
WireConnection;16;0;10;0
WireConnection;16;1;8;0
WireConnection;18;0;16;0
WireConnection;18;1;12;0
WireConnection;24;0;18;0
WireConnection;25;0;88;0
WireConnection;25;1;24;0
WireConnection;38;0;25;0
WireConnection;102;0;104;0
WireConnection;102;1;103;0
WireConnection;102;2;38;0
WireConnection;108;0;110;0
WireConnection;108;1;109;0
WireConnection;107;0;102;0
WireConnection;107;1;108;0
WireConnection;107;2;106;0
WireConnection;0;13;107;0
ASEEND*/
//CHKSM=E909CDBACB7E7A75CAF207B62AA0751301D7EF3F