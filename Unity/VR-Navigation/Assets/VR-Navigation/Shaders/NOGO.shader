// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "NOGO"
{
	Properties
	{
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		_TextureSample1("Texture Sample 1", 2D) = "white" {}
		_TilingNoise("TilingNoise", Vector) = (0.1,0.1,0,0)
		_TilingMask("TilingMask", Vector) = (0.1,0.1,0,0)
		_Speed("Speed", Vector) = (0.1,0.1,0,0)
		_MinMapOld("MinMapOld", Float) = 0
		_MaxMapOld("MaxMapOld", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _TextureSample1;
		uniform float2 _Speed;
		uniform float2 _TilingNoise;
		uniform float _MinMapOld;
		uniform float _MaxMapOld;
		uniform sampler2D _TextureSample0;
		uniform float2 _TilingMask;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_TexCoord7 = i.uv_texcoord * _TilingNoise;
			float2 panner5 = ( 1.0 * _Time.y * _Speed + uv_TexCoord7);
			float4 tex2DNode6 = tex2D( _TextureSample1, panner5 );
			float temp_output_7_0_g1 = _MinMapOld;
			float4 temp_cast_0 = (temp_output_7_0_g1).xxxx;
			o.Emission = ( ( tex2DNode6 - temp_cast_0 ) / ( _MaxMapOld - temp_output_7_0_g1 ) ).rgb;
			float2 uv_TexCoord11 = i.uv_texcoord * _TilingMask;
			float lerpResult3 = lerp( 0.0 , tex2DNode6.r , tex2D( _TextureSample0, uv_TexCoord11 ).a);
			float lerpResult16 = lerp( 0.0 , lerpResult3 , abs( _SinTime.w ));
			o.Alpha = lerpResult16;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit alpha:fade keepalpha fullforwardshadows 

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
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
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
Version=16900
427;580;1440;812;935.6125;65.57378;1.79969;True;True
Node;AmplifyShaderEditor.Vector2Node;8;-771.7593,642.8124;Float;False;Property;_TilingNoise;TilingNoise;2;0;Create;True;0;0;False;0;0.1,0.1;0.05,0.05;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;7;-463.3016,658.03;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;9;-610.684,61.24618;Float;False;Property;_Speed;Speed;4;0;Create;True;0;0;False;0;0.1,0.1;0,0.015;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;10;-920.9667,388.4829;Float;False;Property;_TilingMask;TilingMask;3;0;Create;True;0;0;False;0;0.1,0.1;0.7,0.7;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;11;-851.45,122.2851;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;5;-184.4329,557.76;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;1;-630.6339,366.7569;Float;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;False;0;e746bf484e702c844ba7f4fef31917b6;e746bf484e702c844ba7f4fef31917b6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;6;3.656554,541.6733;Float;True;Property;_TextureSample1;Texture Sample 1;1;0;Create;True;0;0;False;0;None;80abf0a1b524241c2b45ab0cfa0b52d4;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SinTimeNode;15;399.7579,1133.02;Float;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;13;23.81222,818.2983;Float;False;Property;_MinMapOld;MinMapOld;5;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;17.03008,935.2903;Float;False;Property;_MaxMapOld;MaxMapOld;6;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;3;318.4878,222.8221;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;17;730.9009,1147.418;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;12;432.6624,723.952;Float;True;Remap To 0-1;-1;;1;5eda8a2bb94ebef4ab0e43d19291cd8b;0;3;6;COLOR;0,0,0,0;False;7;FLOAT;-0.01;False;8;FLOAT;0.3;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;16;730.9009,213.3783;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;878.2275,317.3094;Float;False;True;2;Float;ASEMaterialInspector;0;0;Unlit;NOGO;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;7;0;8;0
WireConnection;11;0;10;0
WireConnection;5;0;7;0
WireConnection;5;2;9;0
WireConnection;1;1;11;0
WireConnection;6;1;5;0
WireConnection;3;1;6;1
WireConnection;3;2;1;4
WireConnection;17;0;15;4
WireConnection;12;6;6;0
WireConnection;12;7;13;0
WireConnection;12;8;14;0
WireConnection;16;1;3;0
WireConnection;16;2;17;0
WireConnection;0;2;12;0
WireConnection;0;9;16;0
ASEEND*/
//CHKSM=2F683BCBD791118CAD16EDC7B2C4EFEDEE0565B6