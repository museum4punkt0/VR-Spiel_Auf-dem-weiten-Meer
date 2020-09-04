// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Turtle"
{
	Properties
	{
		[Enum(ADS Packed,0,ADS QuickMask,1)][Space(10)]_MaskType("Mask Type", Float) = 0
		[BInteractive(_MaskType, 1)]_MaskTypee("# MaskTypee", Float) = 0
		[Enum(X Axis,0,Y Axis,1,Z Axis,2)]_MaskAxis("Mask Axis", Float) = 1
		[BInteractive(ON)]_MaskTypeeEnd("# MaskTypee End", Float) = 0
		[BMessage(Warning, The ADS Quick Mask option is slow when using high poly meshes and it will be deprecated soon, _MaskType, 1, 10, 0)]_QuickMaskk("!!! QuickMaskk !!!", Float) = 0
		[Space(10)]_MaskMin("Mask Min", Float) = 0
		_MaskMax("Mask Max", Float) = 1
		_AlbedoCol("AlbedoCol", Color) = (0,0,0,0)
		_AlbedoCol2("AlbedoCol2", Color) = (0,0,0,0)
		_Matcap("Matcap", 2D) = "white" {}
		_AmplitudeVal("AmplitudeVal", Float) = 0
		_SpeedVal("SpeedVal", Float) = 0
		_FresnelBiasVal("FresnelBiasVal", Range( 0 , 1)) = 0
		_Falloff("Falloff", Range( 0 , 1)) = 0.5
		_FresnelPowerVal("FresnelPowerVal", Range( 0 , 6)) = 3.388817
		_NoiseSizeVal("NoiseSizeVal", Range( 1 , 100)) = 1
		_StartPoint("StartPoint", Float) = 0
		_DrawingTex("DrawingTex", 2D) = "white" {}
		_Distribution("Distribution", Float) = 0
		[Toggle]_ToggleGlobalVisibility("Toggle Global Visibility ", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
			float3 worldNormal;
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

		uniform half _MaskTypee;
		uniform half _QuickMaskk;
		uniform half _MaskTypeeEnd;
		uniform half ADS_GlobalScale;
		uniform half ADS_GlobalSpeed;
		uniform float _SpeedVal;
		uniform half ADS_GlobalAmplitude;
		uniform float _AmplitudeVal;
		uniform half3 ADS_GlobalDirection;
		uniform half _MaskAxis;
		uniform half _MaskMin;
		uniform half _MaskMax;
		uniform half _MaskType;
		uniform float _ToggleGlobalVisibility;
		uniform float gTurtle;
		uniform sampler2D _DrawingTex;
		uniform float4 _DrawingTex_ST;
		uniform float _FresnelBiasVal;
		uniform float _FresnelPowerVal;
		uniform float _NoiseSizeVal;
		uniform sampler2D _Matcap;
		uniform float _Falloff;
		uniform float4 _AlbedoCol2;
		uniform float4 _AlbedoCol;
		uniform float _StartPoint;
		uniform float _Distribution;


		float3 mod3D289( float3 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 mod3D289( float4 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 permute( float4 x ) { return mod3D289( ( x * 34.0 + 1.0 ) * x ); }

		float4 taylorInvSqrt( float4 r ) { return 1.79284291400159 - r * 0.85373472095314; }

		float snoise( float3 v )
		{
			const float2 C = float2( 1.0 / 6.0, 1.0 / 3.0 );
			float3 i = floor( v + dot( v, C.yyy ) );
			float3 x0 = v - i + dot( i, C.xxx );
			float3 g = step( x0.yzx, x0.xyz );
			float3 l = 1.0 - g;
			float3 i1 = min( g.xyz, l.zxy );
			float3 i2 = max( g.xyz, l.zxy );
			float3 x1 = x0 - i1 + C.xxx;
			float3 x2 = x0 - i2 + C.yyy;
			float3 x3 = x0 - 0.5;
			i = mod3D289( i);
			float4 p = permute( permute( permute( i.z + float4( 0.0, i1.z, i2.z, 1.0 ) ) + i.y + float4( 0.0, i1.y, i2.y, 1.0 ) ) + i.x + float4( 0.0, i1.x, i2.x, 1.0 ) );
			float4 j = p - 49.0 * floor( p / 49.0 );  // mod(p,7*7)
			float4 x_ = floor( j / 7.0 );
			float4 y_ = floor( j - 7.0 * x_ );  // mod(j,N)
			float4 x = ( x_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 y = ( y_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 h = 1.0 - abs( x ) - abs( y );
			float4 b0 = float4( x.xy, y.xy );
			float4 b1 = float4( x.zw, y.zw );
			float4 s0 = floor( b0 ) * 2.0 + 1.0;
			float4 s1 = floor( b1 ) * 2.0 + 1.0;
			float4 sh = -step( h, 0.0 );
			float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
			float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
			float3 g0 = float3( a0.xy, h.x );
			float3 g1 = float3( a0.zw, h.y );
			float3 g2 = float3( a1.xy, h.z );
			float3 g3 = float3( a1.zw, h.w );
			float4 norm = taylorInvSqrt( float4( dot( g0, g0 ), dot( g1, g1 ), dot( g2, g2 ), dot( g3, g3 ) ) );
			g0 *= norm.x;
			g1 *= norm.y;
			g2 *= norm.z;
			g3 *= norm.w;
			float4 m = max( 0.6 - float4( dot( x0, x0 ), dot( x1, x1 ), dot( x2, x2 ), dot( x3, x3 ) ), 0.0 );
			m = m* m;
			m = m* m;
			float4 px = float4( dot( x0, g0 ), dot( x1, g1 ), dot( x2, g2 ), dot( x3, g3 ) );
			return 42.0 * dot( m, px);
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			half MotionScale60_g298 = ( ADS_GlobalScale * 1.0 );
			half MotionSpeed62_g298 = ( ADS_GlobalSpeed * _SpeedVal );
			float mulTime90_g298 = _Time.y * MotionSpeed62_g298;
			float3 temp_output_95_0_g298 = ( ( ase_worldPos * MotionScale60_g298 ) + mulTime90_g298 );
			half MotionVariation269_g298 = 1.0;
			half MotionlAmplitude58_g298 = ( ADS_GlobalAmplitude * _AmplitudeVal );
			float3 temp_output_92_0_g298 = ( sin( ( temp_output_95_0_g298 + MotionVariation269_g298 ) ) * MotionlAmplitude58_g298 );
			half3 GlobalDirection349_g298 = ADS_GlobalDirection;
			float3 lerpResult280_g298 = lerp( GlobalDirection349_g298 , float3(0,1,0) , 0.0);
			half3 MotionDirection59_g298 = mul( unity_WorldToObject, float4( lerpResult280_g298 , 0.0 ) ).xyz;
			float temp_output_25_0_g297 = _MaskAxis;
			float lerpResult24_g297 = lerp( v.texcoord3.x , v.texcoord3.y , saturate( temp_output_25_0_g297 ));
			float lerpResult21_g297 = lerp( lerpResult24_g297 , v.texcoord3.z , step( 2.0 , temp_output_25_0_g297 ));
			half THREE27_g297 = lerpResult21_g297;
			float temp_output_7_0_g296 = _MaskMin;
			float lerpResult42_g295 = lerp( v.color.r , saturate( ( ( THREE27_g297 - temp_output_7_0_g296 ) / ( _MaskMax - temp_output_7_0_g296 ) ) ) , _MaskType);
			half MotionMask137_g298 = lerpResult42_g295;
			float3 temp_output_94_0_g298 = ( ( temp_output_92_0_g298 * MotionDirection59_g298 ) * MotionMask137_g298 );
			v.vertex.xyz += temp_output_94_0_g298;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float2 uv_DrawingTex = i.uv_texcoord * _DrawingTex_ST.xy + _DrawingTex_ST.zw;
			float4 tex2DNode8 = tex2D( _DrawingTex, uv_DrawingTex );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNdotV2 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode2 = ( _FresnelBiasVal + 1.0 * pow( 1.0 - fresnelNdotV2, _FresnelPowerVal ) );
			float simplePerlin3D12 = snoise( ( ase_worldPos * ( 1.0 / _NoiseSizeVal ) ) );
			float blendOpSrc70 = fresnelNode2;
			float blendOpDest70 = saturate( simplePerlin3D12 );
			float lerpResult50 = lerp( tex2DNode8.a , 0.0 , saturate( ( saturate( ( 1.0 - ( ( 1.0 - blendOpDest70) / blendOpSrc70) ) )) ));
			float dotResult91 = dot( ase_worldNormal , ase_worldViewDir );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult5_g294 = dot( ase_worldNormal , ase_worldlightDir );
			float4 appendResult95 = (float4(( dotResult91 * _Falloff ) , (dotResult5_g294*0.5 + 0.5) , 0.0 , 0.0));
			float4 lerpResult99 = lerp( _AlbedoCol2 , _AlbedoCol , saturate( ( ( ase_worldPos.y + _StartPoint ) / _Distribution ) ));
			float4 blendOpSrc111 = tex2D( _Matcap, appendResult95.xy );
			float4 blendOpDest111 = lerpResult99;
			c.rgb = ( saturate( 2.0f*blendOpDest111*blendOpSrc111 + blendOpDest111*blendOpDest111*(1.0f - 2.0f*blendOpSrc111) )).rgb;
			c.a = ( lerp(gTurtle,1.0,_ToggleGlobalVisibility) * lerpResult50 );
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting alpha:fade keepalpha fullforwardshadows exclude_path:deferred nofog vertex:vertexDataFunc 

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
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
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
Version=16900
344;375;1440;812;1810.447;2555.141;5.471987;True;True
Node;AmplifyShaderEditor.CommentaryNode;45;-1772.654,1067.966;Float;False;1239.446;392.7001;Comment;6;17;14;16;13;12;28;Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-1730.127,1331.684;Float;False;Property;_NoiseSizeVal;NoiseSizeVal;23;0;Create;True;0;0;False;0;1;2.3;1;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;16;-1425.418,1320.193;Float;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;14;-1746.641,1123.167;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-1493.99,1133.118;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;85;-147.7963,-513.2095;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;87;238.6986,-439.8543;Float;False;Property;_StartPoint;StartPoint;24;0;Create;True;0;0;False;0;0;-1483.79;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-1754.547,784.5813;Float;False;Property;_FresnelBiasVal;FresnelBiasVal;17;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-1758.048,876.1043;Float;False;Property;_FresnelPowerVal;FresnelPowerVal;19;0;Create;True;0;0;False;0;3.388817;1.6;0;6;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;110;1937.058,-628.61;Float;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;86;2013.046,-809.8203;Float;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NoiseGeneratorNode;12;-1275.143,1132.911;Float;True;Simplex3D;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;88;427.2024,-614.1207;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;28;-787.5682,1124.177;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;90;279.2257,-334.4836;Float;False;Property;_Distribution;Distribution;28;0;Create;True;0;0;False;0;0;-300;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;2;-1460.015,787.2043;Float;False;Standard;WorldNormal;ViewDir;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;89;2370.139,-858.9143;Float;False;Property;_Falloff;Falloff;18;0;Create;True;0;0;False;0;0.5;0.98;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;91;2388.976,-515.0597;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;70;-568.9915,387.8016;Float;True;ColorBurn;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;93;1672.353,-895.3976;Float;False;Half Lambert Term;-1;;294;86299dc21373a954aa5772333626c9c1;0;1;3;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;92;643.9693,-658.7003;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;94;2640.479,-418.6543;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;95;2934.088,-477.9223;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ColorNode;96;947.4972,-723.9287;Float;False;Property;_AlbedoCol2;AlbedoCol2;10;0;Create;True;0;0;False;0;0,0,0,0;0.9528301,0.9528301,0.9528301,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;73;167.126,514.7822;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;98;645.6637,-383.8414;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;8;-1956.416,-829.4619;Float;True;Property;_DrawingTex;DrawingTex;25;0;Create;True;0;0;False;0;d239f476d7f48bf4bb40fa5093cab0d9;d239f476d7f48bf4bb40fa5093cab0d9;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;38;111.8082,-201.4029;Float;False;Global;gTurtle;gTurtle;15;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;97;951.7822,-378.2086;Float;False;Property;_AlbedoCol;AlbedoCol;8;0;Create;True;0;0;False;0;0,0,0,0;0.6297169,0.7917675,0.8396226,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;27;-19.0226,1196.824;Float;False;Property;_AmplitudeVal;AmplitudeVal;15;0;Create;True;0;0;False;0;0;0.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;100;2658.811,-310.7176;Float;True;Property;_Matcap;Matcap;14;0;Create;True;0;0;False;0;None;41eac93c5ee3144ccb92d4dbbdadb1ba;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;26;-83.60912,1339.119;Float;False;Property;_SpeedVal;SpeedVal;16;0;Create;True;0;0;False;0;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;71;-610.0989,-1734.464;Float;False;1634.601;806.8967;Comment;14;55;56;57;58;59;60;61;62;65;54;53;52;64;63;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;99;1896.416,-334.7903;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ToggleSwitchNode;43;511.1046,-175.3718;Float;False;Property;_ToggleGlobalVisibility;Toggle Global Visibility ;33;0;Create;True;0;0;False;0;0;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;25;-155.0505,1491.838;Float;False;ADS Mask Generic;0;;295;2cfc3815568565c4585aebb38bd7a29b;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;50;636.1246,497.4113;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;74;-1260.128,-105.4229;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;59;284.8012,-1098.75;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;60;149.2466,-1254.741;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;458.4651,-1131.382;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;64;-350.2576,-1521.735;Float;False;Property;_ShadowCol;ShadowCol;29;0;Create;True;0;0;False;0;0,0,0,0;0.5877537,0.8714681,0.9811321,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;62;629.3432,-1126.814;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;63;-325.4508,-1684.464;Float;False;Property;_LightCol;LightCol;26;0;Create;True;0;0;False;0;0,0,0,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;65;836.1022,-1116.413;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;24;317.1063,1396.348;Float;False;ADS Motion Generic;12;;298;81cab27e2a487a645a4ff5eb3c63bd27;6,252,1,278,1,228,1,292,1,330,1,326,1;8;220;FLOAT;1;False;221;FLOAT;1;False;222;FLOAT;1;False;218;FLOAT;0;False;287;FLOAT;0;False;136;FLOAT;0;False;279;FLOAT;0;False;342;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;81;-2423.03,-329.2394;Float;False;Property;_Speed;Speed;21;0;Create;True;0;0;False;0;0;1.96;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;82;-2522.979,-148.8459;Float;False;Property;_TimeScale;TimeScale;22;0;Create;True;0;0;False;0;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;84;-2122.51,-521.6498;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;83;-2341.365,-102.5287;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;80;-1484.084,-386.1756;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCFlipBookUVAnimation;78;-2154.546,-371.8506;Float;False;0;0;6;0;FLOAT2;0,0;False;1;FLOAT;2;False;2;FLOAT;2;False;3;FLOAT;0;False;4;FLOAT;1;False;5;FLOAT;0;False;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;56;-223.4098,-1042.167;Float;False;Property;_ShadowSharpness;ShadowSharpness;32;0;Create;True;0;0;False;0;0;1.38;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;136.3099,-1168.72;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;107;1424.482,-1043.967;Float;False;Property;_Color4;Color 4;11;0;Create;True;0;0;False;0;0,0,0,0;1,0.9009434,0.962967,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;57;2.146787,-1190.592;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;66;1669.447,-10.45342;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendOpsNode;111;3026.204,-82.50078;Float;False;SoftLight;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;101;1120.954,-978.739;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;102;1352.405,-838.4324;Float;False;Property;_Color3;Color 3;9;0;Create;True;0;0;False;0;0,0,0,0;0.4643111,0.6589629,0.8867924,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;103;229.1037,-1052.208;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;104;1122.649,-703.88;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;105;1742.488,-814.1505;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;106;904.1882,-934.1593;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;108;672.674,-1128.55;Float;False;Property;_StartPointB;StartPointB;27;0;Create;True;0;0;False;0;0;-703.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;109;838.1347,-1148.114;Float;False;Property;_DistributionB;DistributionB;31;0;Create;True;0;0;False;0;0;-263.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;1041.144,61.93899;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;75;-1867.47,-375.0339;Float;True;Property;_TextureSample0;Texture Sample 0;20;0;Create;True;0;0;False;0;None;433f34449cdfb4f85a8b508f02ff0349;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;53;-560.0989,-1107.226;Float;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;52;-529.6384,-1286.586;Float;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;54;-212.5609,-1243.048;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-217.6548,-1133.023;Float;False;Property;_ShadowOffset;ShadowOffset;30;0;Create;True;0;0;False;0;0;0.13;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2266.324,308.3621;Float;False;True;2;Float;ASEMaterialInspector;0;0;CustomLighting;Turtle;False;False;False;False;False;False;False;False;False;True;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;16;1;17;0
WireConnection;13;0;14;0
WireConnection;13;1;16;0
WireConnection;12;0;13;0
WireConnection;88;0;85;2
WireConnection;88;1;87;0
WireConnection;28;0;12;0
WireConnection;2;1;4;0
WireConnection;2;3;5;0
WireConnection;91;0;86;0
WireConnection;91;1;110;0
WireConnection;70;0;2;0
WireConnection;70;1;28;0
WireConnection;92;0;88;0
WireConnection;92;1;90;0
WireConnection;94;0;91;0
WireConnection;94;1;89;0
WireConnection;95;0;94;0
WireConnection;95;1;93;0
WireConnection;73;0;70;0
WireConnection;98;0;92;0
WireConnection;100;1;95;0
WireConnection;99;0;96;0
WireConnection;99;1;97;0
WireConnection;99;2;98;0
WireConnection;43;0;38;0
WireConnection;50;0;8;4
WireConnection;50;2;73;0
WireConnection;74;0;8;1
WireConnection;74;1;75;1
WireConnection;59;0;58;0
WireConnection;61;0;60;0
WireConnection;61;1;59;0
WireConnection;62;0;61;0
WireConnection;65;0;64;0
WireConnection;65;1;63;0
WireConnection;65;2;62;0
WireConnection;24;220;27;0
WireConnection;24;221;26;0
WireConnection;24;136;25;0
WireConnection;83;0;82;0
WireConnection;80;0;8;4
WireConnection;80;1;75;4
WireConnection;78;0;84;0
WireConnection;78;3;81;0
WireConnection;78;5;83;0
WireConnection;58;0;57;0
WireConnection;58;1;56;0
WireConnection;57;0;54;0
WireConnection;57;1;55;0
WireConnection;66;1;65;0
WireConnection;66;2;8;1
WireConnection;111;0;100;0
WireConnection;111;1;99;0
WireConnection;101;0;106;0
WireConnection;101;1;109;0
WireConnection;104;0;101;0
WireConnection;105;0;107;0
WireConnection;105;1;102;0
WireConnection;105;2;104;0
WireConnection;106;0;103;2
WireConnection;106;1;108;0
WireConnection;39;0;43;0
WireConnection;39;1;50;0
WireConnection;75;1;78;0
WireConnection;54;0;52;0
WireConnection;54;1;53;0
WireConnection;0;9;39;0
WireConnection;0;13;111;0
WireConnection;0;11;24;0
ASEEND*/
//CHKSM=64B09ACDEF4077F5F966E493D28600181DCD5ADC