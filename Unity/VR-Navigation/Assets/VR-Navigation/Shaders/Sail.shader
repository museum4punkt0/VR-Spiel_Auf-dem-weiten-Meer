// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Sail"
{
	Properties
	{
		_Matcap("Matcap", 2D) = "white" {}
		_Falloff("Falloff", Range( 0 , 1)) = 0.5
		_MatcapBlendVal("MatcapBlendVal", Range( 0 , 1)) = 0.6
		_vAmpVal("vAmpVal", Range( 0 , 1)) = 0.2706771
		_vScaleVal("vScaleVal", Range( 0 , 100)) = 0
		_vSpeedVal("vSpeedVal", Range( 0 , 3)) = 0.2186255
		_AlphaMask("AlphaMask", 2D) = "white" {}
		_MinTransparencyVal("MinTransparencyVal", Range( 0 , 1)) = 0
		_MaxTransparencyVal("MaxTransparencyVal", Range( 0 , 1)) = 0
		_UnpaintedSailClothTex("UnpaintedSailClothTex", 2D) = "white" {}
		_PaintedSailClothTex("PaintedSailClothTex", 2D) = "white" {}
		_GraphicTransparancyVal("GraphicTransparancyVal", Range( 0 , 1)) = 0
		_SteerAchievementTex("SteerAchievementTex", 2D) = "white" {}
		_SteerAchievementVal("SteerAchievementVal", Range( 0 , 1)) = 1
		_SunAchievementTex("SunAchievementTex", 2D) = "white" {}
		_SunAchievementVal("SunAchievementVal", Range( 0 , 1)) = 0
		_StarsAchievementTex("StarsAchievementTex", 2D) = "white" {}
		_StarsAchievementVal("StarsAchievementVal", Range( 0 , 1)) = 0
		_CloudsAchievementTex("CloudsAchievementTex", 2D) = "white" {}
		_CloudsAchievementVal("CloudsAchievementVal", Range( 0 , 1)) = 0
		_BirdsAchievementTex("BirdsAchievementTex", 2D) = "white" {}
		_BirdsAchievementVal("BirdsAchievementVal", Range( 0 , 1)) = 0
		_StartTex("StartTex", 2D) = "white" {}
		_StartTurtleVal("StartTurtleVal", Range( 0 , 1)) = 0
		_TurtleMask("TurtleMask", 2D) = "white" {}
		_HintTurtleMask("HintTurtleMask", 2D) = "white" {}
		_TurtleVisibilityVal("TurtleVisibilityVal", Range( 0 , 1)) = 0
		_QuestionMarkVal("QuestionMarkVal", Range( 0 , 1)) = 0
		_QuestionmarkPulseSpeed("QuestionmarkPulseSpeed", Float) = 5.29
		_InflateVal("InflateVal", Range( -2 , 2)) = 0
		[Toggle]_ToggleSun("Toggle Sun", Float) = 1
		[Toggle]_ToggleStars("Toggle Stars", Float) = 1
		[Toggle]_ToggleClouds("Toggle Clouds", Float) = 1
		[Toggle]_ToggleBirds("Toggle Birds", Float) = 1
		[Toggle]_ToggleWaves("Toggle Waves", Float) = 1
		[Toggle]_ToggleTurtle("Toggle Turtle", Float) = 1
		[Toggle]_ToggleQuestionMark("Toggle QuestionMark", Float) = 1
		[Toggle]_ToggleStart("Toggle Start", Float) = 1
		_VertexMovemenMask("VertexMovemenMask", 2D) = "white" {}
		_gSailMovement("gSailMovement", Range( 0 , 1)) = 0
		_NightColFabric("NightColFabric", Color) = (0,0,0,0)
		_NightColPaint("NightColPaint", Color) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			float2 uv_texcoord;
		};

		uniform half ADS_GlobalScale;
		uniform float _vScaleVal;
		uniform half ADS_GlobalSpeed;
		uniform float _vSpeedVal;
		uniform half ADS_GlobalAmplitude;
		uniform float _vAmpVal;
		uniform half3 ADS_GlobalDirection;
		uniform float _InflateVal;
		uniform float _gSailMovement;
		uniform sampler2D _VertexMovemenMask;
		uniform float4 _VertexMovemenMask_ST;
		uniform sampler2D _Matcap;
		uniform float _Falloff;
		uniform sampler2D _UnpaintedSailClothTex;
		uniform float4 _UnpaintedSailClothTex_ST;
		uniform float4 _NightColFabric;
		uniform float NightTransitionMaterial;
		uniform sampler2D _PaintedSailClothTex;
		uniform float4 _PaintedSailClothTex_ST;
		uniform float4 _NightColPaint;
		uniform sampler2D _SteerAchievementTex;
		uniform float4 _SteerAchievementTex_ST;
		uniform sampler2D _StartTex;
		uniform float4 _StartTex_ST;
		uniform float _ToggleStart;
		uniform float _StartTurtleVal;
		uniform float gStartTurtleGraphic;
		uniform float _ToggleWaves;
		uniform float _SteerAchievementVal;
		uniform float gWavesGraphic;
		uniform sampler2D _SunAchievementTex;
		uniform float4 _SunAchievementTex_ST;
		uniform float _ToggleSun;
		uniform float _SunAchievementVal;
		uniform float gSunGraphic;
		uniform sampler2D _StarsAchievementTex;
		uniform float4 _StarsAchievementTex_ST;
		uniform float _ToggleStars;
		uniform float _StarsAchievementVal;
		uniform float gStarsGraphic;
		uniform sampler2D _CloudsAchievementTex;
		uniform float4 _CloudsAchievementTex_ST;
		uniform float _ToggleClouds;
		uniform float _CloudsAchievementVal;
		uniform float gCloudsGraphic;
		uniform sampler2D _BirdsAchievementTex;
		uniform float4 _BirdsAchievementTex_ST;
		uniform float _ToggleBirds;
		uniform float _BirdsAchievementVal;
		uniform float gBirdsGraphic;
		uniform sampler2D _TurtleMask;
		uniform float4 _TurtleMask_ST;
		uniform sampler2D _HintTurtleMask;
		uniform float4 _HintTurtleMask_ST;
		uniform float _QuestionmarkPulseSpeed;
		uniform float _ToggleQuestionMark;
		uniform float _QuestionMarkVal;
		uniform float gQuestionmarkGraphic;
		uniform float _ToggleTurtle;
		uniform float _TurtleVisibilityVal;
		uniform float gTurtleGraphic;
		uniform float _MatcapBlendVal;
		uniform float _GraphicTransparancyVal;
		uniform sampler2D _AlphaMask;
		uniform float _MinTransparencyVal;
		uniform float _MaxTransparencyVal;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			half MotionScale60_g290 = ( ADS_GlobalScale * _vScaleVal );
			half MotionSpeed62_g290 = ( ADS_GlobalSpeed * _vSpeedVal );
			float mulTime90_g290 = _Time.y * MotionSpeed62_g290;
			float2 temp_output_95_0_g290 = ( ( (ase_worldPos).xz * MotionScale60_g290 ) + mulTime90_g290 );
			half MotionVariation269_g290 = 1.0;
			half MotionlAmplitude58_g290 = ( ADS_GlobalAmplitude * _vAmpVal );
			float2 temp_output_92_0_g290 = ( sin( ( temp_output_95_0_g290 + MotionVariation269_g290 ) ) * MotionlAmplitude58_g290 );
			half3 GlobalDirection349_g290 = ADS_GlobalDirection;
			float3 break339_g290 = mul( unity_WorldToObject, float4( GlobalDirection349_g290 , 0.0 ) ).xyz;
			float2 appendResult340_g290 = (float2(break339_g290.x , break339_g290.z));
			half2 MotionDirection59_g290 = appendResult340_g290;
			half MotionMask137_g290 = 1.0;
			float2 temp_output_94_0_g290 = ( ( temp_output_92_0_g290 * MotionDirection59_g290 ) * MotionMask137_g290 );
			float2 break311_g290 = temp_output_94_0_g290;
			float3 appendResult308_g290 = (float3(break311_g290.x , 0.0 , break311_g290.y));
			float3 ase_vertexNormal = v.normal.xyz;
			float3 lerpResult120 = lerp( appendResult308_g290 , ( ase_vertexNormal * _InflateVal ) , _gSailMovement);
			float2 uv_VertexMovemenMask = v.texcoord * _VertexMovemenMask_ST.xy + _VertexMovemenMask_ST.zw;
			float3 lerpResult122 = lerp( lerpResult120 , float3( 0,0,0 ) , ( 1.0 - tex2Dlod( _VertexMovemenMask, float4( uv_VertexMovemenMask, 0, 0.0) ).r ));
			v.vertex.xyz += lerpResult122;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_worldNormal = i.worldNormal;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult29 = dot( ase_worldNormal , ase_worldViewDir );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult5_g279 = dot( ase_worldNormal , ase_worldlightDir );
			float4 appendResult27 = (float4(( dotResult29 * _Falloff ) , (dotResult5_g279*0.5 + 0.5) , 0.0 , 0.0));
			float2 uv_UnpaintedSailClothTex = i.uv_texcoord * _UnpaintedSailClothTex_ST.xy + _UnpaintedSailClothTex_ST.zw;
			float4 lerpResult135 = lerp( float4( 1,1,1,0 ) , _NightColFabric , NightTransitionMaterial);
			float2 uv_PaintedSailClothTex = i.uv_texcoord * _PaintedSailClothTex_ST.xy + _PaintedSailClothTex_ST.zw;
			float4 lerpResult139 = lerp( float4( 1,1,1,0 ) , _NightColPaint , NightTransitionMaterial);
			float2 uv_SteerAchievementTex = i.uv_texcoord * _SteerAchievementTex_ST.xy + _SteerAchievementTex_ST.zw;
			float2 uv_StartTex = i.uv_texcoord * _StartTex_ST.xy + _StartTex_ST.zw;
			float lerpResult131 = lerp( 0.0 , tex2D( _StartTex, uv_StartTex ).r , (( _ToggleStart )?( gStartTurtleGraphic ):( _StartTurtleVal )));
			float lerpResult61 = lerp( 0.0 , ( tex2D( _SteerAchievementTex, uv_SteerAchievementTex ).r - lerpResult131 ) , (( _ToggleWaves )?( gWavesGraphic ):( _SteerAchievementVal )));
			float2 uv_SunAchievementTex = i.uv_texcoord * _SunAchievementTex_ST.xy + _SunAchievementTex_ST.zw;
			float lerpResult60 = lerp( 0.0 , tex2D( _SunAchievementTex, uv_SunAchievementTex ).r , (( _ToggleSun )?( gSunGraphic ):( _SunAchievementVal )));
			float2 uv_StarsAchievementTex = i.uv_texcoord * _StarsAchievementTex_ST.xy + _StarsAchievementTex_ST.zw;
			float lerpResult62 = lerp( 0.0 , tex2D( _StarsAchievementTex, uv_StarsAchievementTex ).r , (( _ToggleStars )?( gStarsGraphic ):( _StarsAchievementVal )));
			float2 uv_CloudsAchievementTex = i.uv_texcoord * _CloudsAchievementTex_ST.xy + _CloudsAchievementTex_ST.zw;
			float lerpResult63 = lerp( 0.0 , tex2D( _CloudsAchievementTex, uv_CloudsAchievementTex ).r , (( _ToggleClouds )?( gCloudsGraphic ):( _CloudsAchievementVal )));
			float2 uv_BirdsAchievementTex = i.uv_texcoord * _BirdsAchievementTex_ST.xy + _BirdsAchievementTex_ST.zw;
			float lerpResult64 = lerp( 0.0 , tex2D( _BirdsAchievementTex, uv_BirdsAchievementTex ).r , (( _ToggleBirds )?( gBirdsGraphic ):( _BirdsAchievementVal )));
			float temp_output_65_0 = ( lerpResult61 + lerpResult60 + lerpResult62 + lerpResult63 + lerpResult64 + lerpResult131 );
			float4 temp_cast_1 = (temp_output_65_0).xxxx;
			float2 uv_TurtleMask = i.uv_texcoord * _TurtleMask_ST.xy + _TurtleMask_ST.zw;
			float2 uv_HintTurtleMask = i.uv_texcoord * _HintTurtleMask_ST.xy + _HintTurtleMask_ST.zw;
			float lerpResult112 = lerp( 0.0 , tex2D( _HintTurtleMask, uv_HintTurtleMask ).r , (0.2 + ((sin( ( _QuestionmarkPulseSpeed * _Time.y ) )*0.5 + 0.5) - 0.0) * (1.1 - 0.2) / (1.0 - 0.0)));
			float lerpResult150 = lerp( 0.0 , lerpResult112 , (( _ToggleQuestionMark )?( gQuestionmarkGraphic ):( _QuestionMarkVal )));
			float4 lerpResult72 = lerp( float4( 0,0,0,0 ) , ( tex2D( _TurtleMask, uv_TurtleMask ) + lerpResult150 ) , (( _ToggleTurtle )?( gTurtleGraphic ):( _TurtleVisibilityVal )));
			float4 temp_output_128_0 = ( temp_cast_1 - lerpResult72 );
			float4 lerpResult76 = lerp( ( tex2D( _UnpaintedSailClothTex, uv_UnpaintedSailClothTex ) * lerpResult135 ) , ( tex2D( _PaintedSailClothTex, uv_PaintedSailClothTex ) * lerpResult139 ) , temp_output_128_0);
			float4 blendOpSrc46 = tex2D( _Matcap, appendResult27.xy );
			float4 blendOpDest46 = lerpResult76;
			float4 lerpBlendMode46 = lerp(blendOpDest46,2.0f*blendOpDest46*blendOpSrc46 + blendOpDest46*blendOpDest46*(1.0f - 2.0f*blendOpSrc46),_MatcapBlendVal);
			o.Emission = ( ( saturate( lerpBlendMode46 )) + lerpResult150 ).rgb;
			float4 temp_cast_3 = (temp_output_65_0).xxxx;
			float4 clampResult83 = clamp( ( ( temp_output_128_0 * _GraphicTransparancyVal ) + (_MinTransparencyVal + (( 1.0 - tex2D( _AlphaMask, i.uv_texcoord ).r ) - 0.0) * (_MaxTransparencyVal - _MinTransparencyVal) / (1.0 - 0.0)) ) , float4( 0,0,0,0 ) , float4( 1,0,0,0 ) );
			o.Alpha = clampResult83.r;
		}

		ENDCG
		CGPROGRAM
		#pragma exclude_renderers vulkan xbox360 xboxone ps4 psp2 n3ds wiiu 
		#pragma surface surf Standard alpha:fade keepalpha fullforwardshadows vertex:vertexDataFunc 

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
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
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
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
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
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
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
802;405;1440;732;2259.81;632.6637;1.087629;True;True
Node;AmplifyShaderEditor.RangedFloatNode;145;-3362.146,863.1077;Float;False;Property;_QuestionmarkPulseSpeed;QuestionmarkPulseSpeed;28;0;Create;True;0;0;False;0;5.29;6.23;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;147;-3236.811,1135.387;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;148;-2980.379,984.1208;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;146;-2911.229,806.9232;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;130;-1880.132,2643.232;Float;False;Global;gStartTurtleGraphic;gStartTurtleGraphic;29;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;132;-2065.132,2551.886;Float;False;Property;_StartTurtleVal;StartTurtleVal;23;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;116;-2806.516,631.1714;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;71;-2040.222,689.5496;Inherit;False;1021.554;1489.928;// AchievementGraphic;27;70;61;58;62;67;60;56;63;57;68;69;55;66;65;64;59;99;100;101;102;104;103;106;105;108;107;127;// AchievementGraphic;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;151;-2852.52,63.19888;Inherit;False;Global;gQuestionmarkGraphic;gQuestionmarkGraphic;40;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;129;-1521.279,2465.433;Float;False;Property;_ToggleStart;Toggle Start;37;0;Create;True;0;0;False;0;1;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;126;-2048.251,2317.001;Inherit;True;Property;_StartTex;StartTex;22;0;Create;True;0;0;False;0;-1;None;31512655dcef14ccaad3b048dce65732;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;152;-2970.059,-30.51826;Float;False;Property;_QuestionMarkVal;QuestionMarkVal;27;0;Create;True;0;0;False;0;0;0.884;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;111;-3276.93,100.2877;Inherit;True;Property;_HintTurtleMask;HintTurtleMask;25;0;Create;True;0;0;False;0;-1;None;e5b981d6bbe41487e97a3c261bde4328;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;149;-2530.864,631.8629;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0.2;False;4;FLOAT;1.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;68;-1969.289,1448.51;Float;False;Property;_StarsAchievementVal;StarsAchievementVal;17;0;Create;True;0;0;False;0;0;0.93;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;66;-1977.917,923.9169;Float;False;Property;_SteerAchievementVal;SteerAchievementVal;13;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-1949.887,1738.863;Float;False;Property;_CloudsAchievementVal;CloudsAchievementVal;19;0;Create;True;0;0;False;0;0;0.921;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;100;-1652.572,1225.518;Float;False;Global;gSunGraphic;gSunGraphic;29;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;131;-1305.511,2335.62;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;70;-1947.136,2065.533;Float;False;Property;_BirdsAchievementVal;BirdsAchievementVal;21;0;Create;True;0;0;False;0;0;0.938;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;112;-2688.229,200.896;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;106;-1641.124,1779.113;Float;False;Global;gCloudsGraphic;gCloudsGraphic;29;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;153;-2580.386,-122.9524;Float;False;Property;_ToggleQuestionMark;Toggle QuestionMark;36;0;Create;True;0;0;False;0;1;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;40;-2000.636,-1090.778;Inherit;False;1083.712;407.7859;Matcap;9;29;28;24;27;32;31;30;26;47;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;102;-1670.901,988.5511;Float;False;Global;gWavesGraphic;gWavesGraphic;29;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;55;-2186.582,727.4036;Inherit;True;Property;_SteerAchievementTex;SteerAchievementTex;12;0;Create;True;0;0;False;0;-1;80ee511a5808d8d499a8ca850b8a2129;01c33e3cc6c7346babeff71989f7fff8;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;74;-2043.99,-51.10345;Inherit;False;1035.59;618.962;Comment;6;43;45;72;109;110;118;//TurtleGraphic;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;104;-1650.343,1451.825;Float;False;Global;gStarsGraphic;gStarsGraphic;29;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;107;-1633.423,2149.488;Float;False;Global;gBirdsGraphic;gBirdsGraphic;29;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;67;-1974.797,1185.994;Float;False;Property;_SunAchievementVal;SunAchievementVal;15;0;Create;True;0;0;False;0;0;0.934;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;127;-1850.828,741.0787;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;101;-1688.25,884.2834;Float;False;Property;_ToggleWaves;Toggle Waves;34;0;Create;True;0;0;False;0;1;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;56;-1987.116,1000.637;Inherit;True;Property;_SunAchievementTex;SunAchievementTex;14;0;Create;True;0;0;False;0;-1;None;9991063e2ee5547de832a18320f5bde4;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;73;-2061.045,2793.793;Inherit;False;1014.027;540.2039;Comment;7;20;34;22;21;23;33;80;Transparency;1,1,1,1;0;0
Node;AmplifyShaderEditor.ToggleSwitchNode;99;-1682.599,1115.488;Float;False;Property;_ToggleSun;Toggle Sun;30;0;Create;True;0;0;False;0;1;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;110;-1881.446,279.1171;Float;False;Global;gTurtleGraphic;gTurtleGraphic;29;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;58;-1975.238,1532.201;Inherit;True;Property;_CloudsAchievementTex;CloudsAchievementTex;18;0;Create;True;0;0;False;0;-1;None;1196ceb77db85442b8a6d0ddb7e6d94a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;59;-1976.191,1834.168;Inherit;True;Property;_BirdsAchievementTex;BirdsAchievementTex;20;0;Create;True;0;0;False;0;-1;None;dc8b07b0ff65e412faf1b1979255e487;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;32;-1935.178,-865.3916;Float;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;31;-1950.635,-1013.274;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ToggleSwitchNode;103;-1675.76,1341.796;Float;False;Property;_ToggleStars;Toggle Stars;31;0;Create;True;0;0;False;0;1;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-1967.723,201.019;Float;False;Property;_TurtleVisibilityVal;TurtleVisibilityVal;26;0;Create;True;0;0;False;0;0;0.884;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;45;-2001.898,-20.84329;Inherit;True;Property;_TurtleMask;TurtleMask;24;0;Create;True;0;0;False;0;-1;None;d1d5b90fad9d6434ea25087549745ffb;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ToggleSwitchNode;105;-1636.578,1597.633;Float;False;Property;_ToggleClouds;Toggle Clouds;32;0;Create;True;0;0;False;0;1;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;57;-1980.508,1261.191;Inherit;True;Property;_StarsAchievementTex;StarsAchievementTex;16;0;Create;True;0;0;False;0;-1;None;bdca5fec9df9d4348b2c8ec40d39ccb6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;150;-2293.642,-5.555389;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;108;-1562.826,1967.465;Float;False;Property;_ToggleBirds;Toggle Birds;33;0;Create;True;0;0;False;0;1;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;29;-1707.615,-1013.755;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;118;-1464.469,18.69749;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;60;-1424.12,1011.125;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;133;-1348.815,-565.5692;Float;False;Property;_NightColFabric;NightColFabric;40;0;Create;True;0;0;False;0;0,0,0,0;0.3755273,0.2390528,0.6415094,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ToggleSwitchNode;109;-1679.138,205.3333;Float;False;Property;_ToggleTurtle;Toggle Turtle;35;0;Create;True;0;0;False;0;1;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;63;-1380.212,1548.58;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;140;-1377.414,-318.8305;Float;False;Property;_NightColPaint;NightColPaint;41;0;Create;True;0;0;False;0;0,0,0,0;0.6037736,0,0.3359322,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;136;-1926.92,-355.9608;Float;False;Global;NightTransitionMaterial;NightTransitionMaterial;41;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;22;-2011.045,2865.613;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;62;-1429.845,1287.92;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;61;-1533.145,726.0278;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;64;-1360.785,1864.05;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-1719.262,-806.1843;Float;False;Property;_Falloff;Falloff;1;0;Create;True;0;0;False;0;0.5;0.698;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;139;-1012.758,-295.9558;Inherit;True;3;0;COLOR;1,1,1,0;False;1;COLOR;1,1,1,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;14;-628.5553,-603.4227;Inherit;True;Property;_UnpaintedSailClothTex;UnpaintedSailClothTex;9;0;Create;True;0;0;False;0;-1;None;9ff5aba77e2b84c548b1d6b3740f5ace;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;65;-1244.546,749.6959;Inherit;True;6;6;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;135;-984.1586,-542.6946;Inherit;True;3;0;COLOR;1,1,1,0;False;1;COLOR;1,1,1,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;72;-1273.312,13.94419;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-1550.922,-1015.873;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;24;-1696.983,-901.9695;Inherit;False;Half Lambert Term;-1;;279;86299dc21373a954aa5772333626c9c1;0;1;3;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;77;-674.1009,-59.07257;Inherit;True;Property;_PaintedSailClothTex;PaintedSailClothTex;10;0;Create;True;0;0;False;0;-1;None;542204836d02645788461a3e5bfe8fd7;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;21;-1764.583,2843.793;Inherit;True;Property;_AlphaMask;AlphaMask;6;0;Create;True;0;0;False;0;-1;None;9d4b5586372034f6fa4d673041b5a80c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;142;-312.8593,-187.0315;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;128;-660.876,701.9688;Inherit;True;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;23;-1434.942,2853.444;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-1709.545,3838.708;Float;False;Property;_vAmpVal;vAmpVal;3;0;Create;True;0;0;False;0;0.2706771;0.098;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-1570.125,3062.009;Float;False;Property;_MinTransparencyVal;MinTransparencyVal;7;0;Create;True;0;0;False;0;0;0.278;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;80;-1446.563,3241.647;Float;False;Property;_GraphicTransparancyVal;GraphicTransparancyVal;11;0;Create;True;0;0;False;0;0;0.314;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-1695.492,3935.75;Float;False;Property;_vSpeedVal;vSpeedVal;5;0;Create;True;0;0;False;0;0.2186255;3;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-1574.662,3150.137;Float;False;Property;_MaxTransparencyVal;MaxTransparencyVal;8;0;Create;True;0;0;False;0;0;0.537;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;141;-317.8742,-390.1408;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;88;-1704.635,3649.509;Float;False;Property;_InflateVal;InflateVal;29;0;Create;True;0;0;False;0;0;-0.67;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;27;-1395.532,-1012.973;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.NormalVertexDataNode;90;-1659.139,3435.535;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;53;-1724.176,4043.231;Float;False;Property;_vScaleVal;vScaleVal;4;0;Create;True;0;0;False;0;0;12.8;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;26;-1239.323,-1040.777;Inherit;True;Property;_Matcap;Matcap;0;0;Create;True;0;0;False;0;-1;None;20a5d7c1b4e944297ac8d0f95e33a12c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;123;-1069.431,4368.927;Inherit;True;Property;_VertexMovemenMask;VertexMovemenMask;38;0;Create;True;0;0;False;0;-1;None;bf7bc8f40e5ca44b9b271f09c4d40253;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;47;-1229.076,-814.644;Float;False;Property;_MatcapBlendVal;MatcapBlendVal;2;0;Create;True;0;0;False;0;0.6;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;121;-868.5972,3942.155;Float;False;Property;_gSailMovement;gSailMovement;39;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;-843.5979,2078.59;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;119;-1236.171,3932.639;Inherit;False;ADS Motion Generic;-1;;290;81cab27e2a487a645a4ff5eb3c63bd27;6,252,0,278,1,228,1,292,1,330,0,326,0;8;220;FLOAT;0;False;221;FLOAT;0;False;222;FLOAT;0;False;218;FLOAT;0;False;287;FLOAT;0;False;136;FLOAT;0;False;279;FLOAT;0;False;342;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TFHCRemapNode;33;-1257.018,2878.2;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;-1174.843,3605.844;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;76;209.3173,112.3681;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;75;-654.1376,2399.5;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendOpsNode;46;712.9034,-588.6422;Inherit;False;SoftLight;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0.8;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;125;-205.3097,4108.716;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;120;-434.5295,3655.587;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;122;-11.23877,3630.317;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;78;-637.2375,217.87;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;97;-808.9853,374.9366;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;143;979.7339,-123.3046;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;83;-342.7367,2100.825;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;98;-405.6213,220.4525;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1378.908,-215.2049;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Sail;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;7;d3d9;d3d11_9x;d3d11;glcore;gles;gles3;metal;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.CommentaryNode;39;974.5259,-1581.353;Inherit;False;100;100;reate a comment group ;0;;1,1,1,1;0;0
WireConnection;148;0;145;0
WireConnection;148;1;147;0
WireConnection;146;0;148;0
WireConnection;116;0;146;0
WireConnection;129;0;132;0
WireConnection;129;1;130;0
WireConnection;149;0;116;0
WireConnection;131;1;126;1
WireConnection;131;2;129;0
WireConnection;112;1;111;1
WireConnection;112;2;149;0
WireConnection;153;0;152;0
WireConnection;153;1;151;0
WireConnection;127;0;55;1
WireConnection;127;1;131;0
WireConnection;101;0;66;0
WireConnection;101;1;102;0
WireConnection;99;0;67;0
WireConnection;99;1;100;0
WireConnection;103;0;68;0
WireConnection;103;1;104;0
WireConnection;105;0;69;0
WireConnection;105;1;106;0
WireConnection;150;1;112;0
WireConnection;150;2;153;0
WireConnection;108;0;70;0
WireConnection;108;1;107;0
WireConnection;29;0;31;0
WireConnection;29;1;32;0
WireConnection;118;0;45;0
WireConnection;118;1;150;0
WireConnection;60;1;56;1
WireConnection;60;2;99;0
WireConnection;109;0;43;0
WireConnection;109;1;110;0
WireConnection;63;1;58;1
WireConnection;63;2;105;0
WireConnection;62;1;57;1
WireConnection;62;2;103;0
WireConnection;61;1;127;0
WireConnection;61;2;101;0
WireConnection;64;1;59;1
WireConnection;64;2;108;0
WireConnection;139;1;140;0
WireConnection;139;2;136;0
WireConnection;65;0;61;0
WireConnection;65;1;60;0
WireConnection;65;2;62;0
WireConnection;65;3;63;0
WireConnection;65;4;64;0
WireConnection;65;5;131;0
WireConnection;135;1;133;0
WireConnection;135;2;136;0
WireConnection;72;1;118;0
WireConnection;72;2;109;0
WireConnection;28;0;29;0
WireConnection;28;1;30;0
WireConnection;21;1;22;0
WireConnection;142;0;77;0
WireConnection;142;1;139;0
WireConnection;128;0;65;0
WireConnection;128;1;72;0
WireConnection;23;0;21;1
WireConnection;141;0;14;0
WireConnection;141;1;135;0
WireConnection;27;0;28;0
WireConnection;27;1;24;0
WireConnection;26;1;27;0
WireConnection;79;0;128;0
WireConnection;79;1;80;0
WireConnection;119;220;50;0
WireConnection;119;221;51;0
WireConnection;119;222;53;0
WireConnection;33;0;23;0
WireConnection;33;3;20;0
WireConnection;33;4;34;0
WireConnection;86;0;90;0
WireConnection;86;1;88;0
WireConnection;76;0;141;0
WireConnection;76;1;142;0
WireConnection;76;2;128;0
WireConnection;75;0;79;0
WireConnection;75;1;33;0
WireConnection;46;0;26;0
WireConnection;46;1;76;0
WireConnection;46;2;47;0
WireConnection;125;0;123;1
WireConnection;120;0;119;0
WireConnection;120;1;86;0
WireConnection;120;2;121;0
WireConnection;122;0;120;0
WireConnection;122;2;125;0
WireConnection;78;0;72;0
WireConnection;78;1;97;0
WireConnection;97;0;65;0
WireConnection;143;0;46;0
WireConnection;143;1;150;0
WireConnection;83;0;75;0
WireConnection;98;0;78;0
WireConnection;0;2;143;0
WireConnection;0;9;83;0
WireConnection;0;11;122;0
ASEEND*/
//CHKSM=4DDE3396DD4600E3DEE46DCD8C4E3CD6FD39EF83