// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Paddle"
{
	Properties
	{
		_Main("Main", 2D) = "white" {}
		_SpecularColor("Specular Color", Color) = (1,1,1,1)
		_Shininess("Glossiness", Float) = 0
		_HiliteMask("HiliteMask", 2D) = "white" {}
		_HiliteVal("HiliteVal", Range( 0 , 1)) = 0
		_ShadowCol("ShadowCol", Color) = (0,0,0,0)
		_Color0("Color 0", Color) = (0,0,0,0)
		_Color2("Color 2", Color) = (0,0,0,0)
		_Color1("Color 1", Color) = (0,0,0,0)
		_ShadowOffset("ShadowOffset", Float) = 0
		_TextureSample4("Texture Sample 4", 2D) = "white" {}
		_ShadowSharpness("ShadowSharpness", Float) = 0
		_TextureSample0("Texture Sample 0", 2D) = "bump" {}
		_ToonrampTex("ToonrampTex", 2D) = "white" {}
		_Float5("Float 5", Float) = 0
		_Float6("Float 6", Float) = 0
		_Float4("Float 4", Float) = 0
		_TextureSample3("Texture Sample 3", 2D) = "white" {}
		_ShadowDetail("ShadowDetail", Range( 0 , 1)) = 0
		_xToonVal("xToonVal", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
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

		uniform sampler2D _HiliteMask;
		uniform float4 _HiliteMask_ST;
		uniform float _HiliteVal;
		uniform float4 _ShadowCol;
		uniform sampler2D _Main;
		uniform float4 _Main_ST;
		uniform float _ShadowDetail;
		uniform float _Float6;
		uniform float _Float4;
		uniform float _Float5;
		uniform float4 _Color0;
		uniform half _Shininess;
		uniform half4 _SpecularColor;
		uniform sampler2D _TextureSample3;
		uniform float4 _TextureSample3_ST;
		uniform sampler2D _ToonrampTex;
		uniform float _xToonVal;
		uniform sampler2D _TextureSample4;
		uniform float4 _TextureSample4_ST;
		uniform sampler2D _TextureSample0;
		uniform float4 _TextureSample0_ST;
		uniform float _ShadowOffset;
		uniform float _ShadowSharpness;
		uniform float4 _Color1;
		uniform float4 _Color2;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float2 uv_HiliteMask = i.uv_texcoord * _HiliteMask_ST.xy + _HiliteMask_ST.zw;
			float4 tex2DNode5 = tex2D( _HiliteMask, uv_HiliteMask );
			float2 uv_Main = i.uv_texcoord * _Main_ST.xy + _Main_ST.zw;
			float4 blendOpSrc4 = tex2DNode5;
			float4 blendOpDest4 = tex2D( _Main, uv_Main );
			float temp_output_8_0 = ( abs( _SinTime.w ) * _HiliteVal );
			float4 lerpBlendMode4 = lerp(blendOpDest4,(( blendOpDest4 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest4 ) * ( 1.0 - blendOpSrc4 ) ) : ( 2.0 * blendOpDest4 * blendOpSrc4 ) ),temp_output_8_0);
			float4 temp_output_4_0 = ( saturate( lerpBlendMode4 ));
			float3 desaturateInitialColor62 = temp_output_4_0.rgb;
			float desaturateDot62 = dot( desaturateInitialColor62, float3( 0.299, 0.587, 0.114 ));
			float3 desaturateVar62 = lerp( desaturateInitialColor62, desaturateDot62.xxx, _ShadowDetail );
			float4 blendOpSrc70 = _ShadowCol;
			float4 blendOpDest70 = float4( desaturateVar62 , 0.0 );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float fresnelNdotV44 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode44 = ( _Float6 + _Float4 * pow( 1.0 - fresnelNdotV44, _Float5 ) );
			float3 temp_output_15_0 = mul( unity_WorldToObject, float4( ase_worldNormal , 0.0 ) ).xyz;
			float dotResult23 = dot( abs( temp_output_15_0 ) , float3(1,1,1) );
			float3 myVarName39 = ( temp_output_15_0 / dotResult23 );
			float lerpResult56 = lerp( 0.0 , fresnelNode44 , myVarName39.y);
			float4 temp_output_60_0 = ( lerpResult56 * _Color0 );
			half3 NORMAL99_g5 = (WorldNormalVector( i , half3(0,0,1) ));
			float3 normalizeResult73_g5 = normalize( NORMAL99_g5 );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 normalizeResult40_g5 = normalize( ( ase_worldViewDir + ase_worldlightDir ) );
			float dotResult45_g5 = dot( normalizeResult73_g5 , normalizeResult40_g5 );
			float4 temp_output_46_12 = ( pow( max( dotResult45_g5 , 0.0 ) , ( 128.0 * max( _Shininess , 0.01 ) ) ) * _SpecularColor );
			float2 uv_TextureSample3 = i.uv_texcoord * _TextureSample3_ST.xy + _TextureSample3_ST.zw;
			float4 lerpResult52 = lerp( temp_output_46_12 , float4( 0,0,0,0 ) , tex2D( _TextureSample3, uv_TextureSample3 ).r);
			float dotResult5_g4 = dot( ase_worldNormal , ase_worldlightDir );
			float4 appendResult34 = (float4((dotResult5_g4*0.5 + 0.5) , _xToonVal , 0.0 , 0.0));
			float4 blendOpSrc69 = temp_output_60_0;
			float4 blendOpDest69 = ( lerpResult52 + ( temp_output_4_0 * tex2D( _ToonrampTex, appendResult34.xy ) ) );
			float2 uv_TextureSample4 = i.uv_texcoord * _TextureSample4_ST.xy + _TextureSample4_ST.zw;
			float2 uv_TextureSample0 = i.uv_texcoord * _TextureSample0_ST.xy + _TextureSample0_ST.zw;
			float dotResult25 = dot( normalize( (WorldNormalVector( i , UnpackNormal( tex2D( _TextureSample0, uv_TextureSample0 ) ) )) ) , ase_worldlightDir );
			float clampResult47 = clamp( ( ( dotResult25 + _ShadowOffset ) * _ShadowSharpness ) , 0.0 , 1.0 );
			float clampResult66 = clamp( ( 0.0 * clampResult47 ) , 0.0 , 1.0 );
			float4 lerpResult75 = lerp( ( saturate( ( blendOpSrc70 * blendOpDest70 ) )) , ( saturate( 	max( blendOpSrc69, blendOpDest69 ) )) , ( tex2D( _TextureSample4, uv_TextureSample4 ) * clampResult66 ));
			float3 temp_output_37_0 = abs( ase_worldNormal );
			float clampResult68 = clamp( ( ase_worldNormal * temp_output_37_0 ).y , 0.0 , 1.0 );
			float4 lerpResult73 = lerp( float4( 0,0,0,0 ) , _Color1 , clampResult68);
			float clampResult65 = clamp( ( -ase_worldNormal * temp_output_37_0 ).y , 0.0 , 1.0 );
			float4 lerpResult71 = lerp( float4( 0,0,0,0 ) , _Color2 , clampResult65);
			c.rgb = ( lerpResult75 + ( lerpResult73 + lerpResult71 ) ).rgb;
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
			float2 uv_HiliteMask = i.uv_texcoord * _HiliteMask_ST.xy + _HiliteMask_ST.zw;
			float4 tex2DNode5 = tex2D( _HiliteMask, uv_HiliteMask );
			float temp_output_8_0 = ( abs( _SinTime.w ) * _HiliteVal );
			float4 lerpResult1 = lerp( tex2DNode5 , float4( 0,0,0,0 ) , temp_output_8_0);
			o.Emission = lerpResult1.rgb;
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
-32;448;2560;1352;1423.124;-1422.085;1.176456;True;True
Node;AmplifyShaderEditor.CommentaryNode;10;-1639.193,752.683;Float;False;1975.473;706.6298;Comment;16;60;56;55;45;44;41;40;39;38;28;23;19;18;15;13;12;Vertical Rim Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldToObjectMatrix;12;-1589.193,802.683;Float;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.WorldNormalVector;13;-1589.193,898.6829;Float;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;11;-2486.738,1611.401;Float;False;831.9146;313.1678;Comment;1;16;Normals;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-1317.193,866.683;Float;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;16;-2178.934,1659.895;Float;True;Property;_TextureSample0;Texture Sample 0;13;0;Create;True;0;0;False;0;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;14;-1616.384,1606.34;Float;False;836.6255;384.7068;Comment;3;25;20;17;WorldDotLight;1,1,1,1;0;0
Node;AmplifyShaderEditor.AbsOpNode;19;-1137.623,969.8752;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;17;-1400.961,1664.064;Float;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;20;-1413.453,1821.316;Float;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;21;-741.7021,1605.62;Float;False;1082.442;371.774;Shadowmask (no color);7;66;57;47;36;29;27;24;Light / ShadowMask;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector3Node;18;-1330.196,1009.532;Float;False;Constant;_Vector2;Vector 2;-1;0;Create;True;0;0;False;0;1,1,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;24;-685.9463,1771.539;Float;False;Property;_ShadowOffset;ShadowOffset;10;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;25;-1149.81,1760.09;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;23;-977.9573,966.8851;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinTimeNode;2;-1817.179,2863.137;Float;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;22;-1587.329,11.05792;Float;False;1927.987;640.3427;Comment;14;74;73;71;68;65;64;61;58;51;49;48;37;35;31;Sky / Ground Bounce Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;26;-594.1547,3465.716;Float;False;887.0688;280;Comment;4;42;34;32;30;xToon Tamp;1,1,1,1;0;0
Node;AmplifyShaderEditor.AbsOpNode;6;-1566.539,2943.302;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-1580.18,3168.639;Float;False;Property;_HiliteVal;HiliteVal;5;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;30;-533.6657,3521.03;Float;False;Half Lambert Term;-1;;4;86299dc21373a954aa5772333626c9c1;0;1;3;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-691.7002,1862.394;Float;False;Property;_ShadowSharpness;ShadowSharpness;12;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-544.1547,3607.344;Float;False;Property;_xToonVal;xToonVal;20;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;27;-466.1422,1713.97;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;28;-821.1931,866.683;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;31;-1537.329,162.8492;Float;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;34;-223.6578,3521.996;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-1564.332,1148.883;Float;False;Property;_Float6;Float 6;16;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;35;-1293.092,336.7476;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-1156.127,3144.801;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;39;-661.1931,866.683;Float;True;myVarName;1;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.AbsOpNode;37;-1286.761,249.3505;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-1567.645,1249.91;Float;False;Property;_Float4;Float 4;17;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;33;-405.7052,2460.927;Float;False;711.775;387.9122;Comment;3;52;50;46;Specular;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-331.9802,1735.842;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;5;-1905.895,2540.753;Float;True;Property;_HiliteMask;HiliteMask;4;0;Create;True;0;0;False;0;None;eb58675e7b19ab944a7c1873782bcb12;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;40;-1569.302,1344.313;Float;False;Property;_Float5;Float 5;15;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-1800.279,2283.537;Float;True;Property;_Main;Main;0;0;Create;True;0;0;False;0;None;19a4335a524714398a9b65d62095d474;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;-1105.266,318.4097;Float;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;42;-24.08383,3515.716;Float;True;Property;_ToonrampTex;ToonrampTex;14;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FresnelNode;44;-1180.053,1183.115;Float;False;Standard;WorldNormal;ViewDir;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;50;-355.7052,2618.839;Float;True;Property;_TextureSample3;Texture Sample 3;18;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BlendOpsNode;4;-1073.213,2403.286;Float;False;Overlay;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;47;-183.4882,1805.812;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;45;-430.6241,868.3268;Float;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.FunctionNode;46;-263.1492,2520.795;Float;False;Lighting Specular;1;;5;503457513f257784c866265a383a60d7;1,103,2;2;100;FLOAT3;0,0,0;False;102;FLOAT3;0,0,0;False;1;COLOR;12
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;-1105.767,68.34296;Float;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;55;-806.3491,1185.679;Float;False;Property;_Color0;Color 0;7;0;Create;True;0;0;False;0;0,0,0,0;1,0.8584198,0.6745283,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;-9.825195,1773.18;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;669.9728,3094.433;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;54;592.5832,2701.856;Float;False;Property;_ShadowDetail;ShadowDetail;19;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;52;127.5908,2513.688;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;56;-170.0482,862.3762;Float;True;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;58;-870.0481,321.6329;Float;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.BreakToComponentsNode;51;-879.6431,71.56348;Float;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.ClampOpNode;68;-626.1301,74.74237;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;67;751.7372,2262.457;Float;False;Property;_ShadowCol;ShadowCol;6;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;65;-612.8281,316.9816;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;61;-477.6392,203.0074;Float;False;Property;_Color1;Color 1;9;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;101.2778,856.3799;Float;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DesaturateOpNode;62;582.6931,2468.049;Float;True;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;63;891.8591,1404.634;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;64;-480.6353,444.4006;Float;False;Property;_Color2;Color 2;8;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;59;59.65784,2002.584;Float;True;Property;_TextureSample4;Texture Sample 4;11;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;66;161.0548,1777.748;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;73;-172.8302,61.05792;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendOpsNode;69;1057.577,1159.098;Float;True;Lighten;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;546.8538,1834.41;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;71;-160.5342,337.4611;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendOpsNode;70;1259.935,2596.224;Float;False;Multiply;True;3;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;74;105.6578,187.8759;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;75;1892.716,1724.237;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;76;2272.854,1090.792;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;1;-958.8146,2748.861;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;77;-88.80322,2188.699;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2633.415,507.3508;Float;False;True;2;Float;ASEMaterialInspector;0;0;CustomLighting;Paddle;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;15;0;12;0
WireConnection;15;1;13;0
WireConnection;19;0;15;0
WireConnection;17;0;16;0
WireConnection;25;0;17;0
WireConnection;25;1;20;0
WireConnection;23;0;19;0
WireConnection;23;1;18;0
WireConnection;6;0;2;4
WireConnection;27;0;25;0
WireConnection;27;1;24;0
WireConnection;28;0;15;0
WireConnection;28;1;23;0
WireConnection;34;0;30;0
WireConnection;34;1;32;0
WireConnection;35;0;31;0
WireConnection;8;0;6;0
WireConnection;8;1;7;0
WireConnection;39;0;28;0
WireConnection;37;0;31;0
WireConnection;36;0;27;0
WireConnection;36;1;29;0
WireConnection;49;0;35;0
WireConnection;49;1;37;0
WireConnection;42;1;34;0
WireConnection;44;1;41;0
WireConnection;44;2;38;0
WireConnection;44;3;40;0
WireConnection;4;0;5;0
WireConnection;4;1;3;0
WireConnection;4;2;8;0
WireConnection;47;0;36;0
WireConnection;45;0;39;0
WireConnection;48;0;31;0
WireConnection;48;1;37;0
WireConnection;57;1;47;0
WireConnection;53;0;4;0
WireConnection;53;1;42;0
WireConnection;52;0;46;12
WireConnection;52;2;50;1
WireConnection;56;1;44;0
WireConnection;56;2;45;1
WireConnection;58;0;49;0
WireConnection;51;0;48;0
WireConnection;68;0;51;1
WireConnection;65;0;58;1
WireConnection;60;0;56;0
WireConnection;60;1;55;0
WireConnection;62;0;4;0
WireConnection;62;1;54;0
WireConnection;63;0;52;0
WireConnection;63;1;53;0
WireConnection;66;0;57;0
WireConnection;73;1;61;0
WireConnection;73;2;68;0
WireConnection;69;0;60;0
WireConnection;69;1;63;0
WireConnection;72;0;59;0
WireConnection;72;1;66;0
WireConnection;71;1;64;0
WireConnection;71;2;65;0
WireConnection;70;0;67;0
WireConnection;70;1;62;0
WireConnection;74;0;73;0
WireConnection;74;1;71;0
WireConnection;75;0;70;0
WireConnection;75;1;69;0
WireConnection;75;2;72;0
WireConnection;76;0;75;0
WireConnection;76;1;74;0
WireConnection;1;0;5;0
WireConnection;1;2;8;0
WireConnection;77;0;60;0
WireConnection;77;1;46;12
WireConnection;0;2;1;0
WireConnection;0;13;76;0
ASEEND*/
//CHKSM=6EF4E92D81407E4DE52DD4C9B77C4EB56D618421