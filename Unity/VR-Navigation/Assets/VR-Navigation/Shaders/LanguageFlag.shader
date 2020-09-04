// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "LanguageFlag"
{
	Properties
	{
		_FlagTex("FlagTex", 2D) = "white" {}
		_AmpVal("AmpVal", Range( 0 , 4)) = 0
		_ScaleVal("ScaleVal", Range( 0 , 4)) = 0
		_Float0("Float 0", Float) = 5
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
		};

		uniform half ADS_GlobalScale;
		uniform float _ScaleVal;
		uniform half ADS_GlobalSpeed;
		uniform half ADS_GlobalAmplitude;
		uniform float _AmpVal;
		uniform half3 ADS_GlobalDirection;
		uniform float _Float0;
		uniform sampler2D _FlagTex;
		uniform float4 _FlagTex_ST;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			half MotionScale60_g1 = ( ADS_GlobalScale * _ScaleVal );
			half MotionSpeed62_g1 = ( ADS_GlobalSpeed * 1.0 );
			float mulTime90_g1 = _Time.y * MotionSpeed62_g1;
			float3 temp_output_95_0_g1 = ( ( ase_worldPos * MotionScale60_g1 ) + mulTime90_g1 );
			half MotionVariation269_g1 = 1.0;
			half MotionlAmplitude58_g1 = ( ADS_GlobalAmplitude * _AmpVal );
			float3 temp_output_92_0_g1 = ( sin( ( temp_output_95_0_g1 + MotionVariation269_g1 ) ) * MotionlAmplitude58_g1 );
			half3 GlobalDirection349_g1 = ADS_GlobalDirection;
			float simplePerlin2D6 = snoise( v.texcoord.xy );
			float3 lerpResult280_g1 = lerp( GlobalDirection349_g1 , float3(0,1,0) , ( _Float0 * simplePerlin2D6 ));
			half3 MotionDirection59_g1 = mul( unity_WorldToObject, float4( lerpResult280_g1 , 0.0 ) ).xyz;
			half MotionMask137_g1 = 1.0;
			float3 temp_output_94_0_g1 = ( ( temp_output_92_0_g1 * MotionDirection59_g1 ) * MotionMask137_g1 );
			v.vertex.xyz += temp_output_94_0_g1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_FlagTex = i.uv_texcoord * _FlagTex_ST.xy + _FlagTex_ST.zw;
			o.Albedo = tex2D( _FlagTex, uv_FlagTex ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16900
-15.2;200;1731;1058;2174.426;676.994;2.172756;True;True
Node;AmplifyShaderEditor.TextureCoordinatesNode;7;-398.8364,677.1307;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NoiseGeneratorNode;6;-76.09877,835.9977;Float;False;Simplex2D;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-512.3182,567.8947;Float;False;Property;_Float0;Float 0;5;0;Create;True;0;0;False;0;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-719.565,192.5914;Float;False;Property;_AmpVal;AmpVal;3;0;Create;True;0;0;False;0;0;0.11;0;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-582.5,384.5;Float;False;Property;_ScaleVal;ScaleVal;4;0;Create;True;0;0;False;0;0;0.84;0;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;119.2465,675.8447;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-368,-70.5;Float;True;Property;_FlagTex;FlagTex;0;0;Create;True;0;0;False;0;None;6c15644ad86f7451abe75d9b837bdc2e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;2;-221,234.5;Float;False;ADS Motion Generic;1;;1;81cab27e2a487a645a4ff5eb3c63bd27;6,252,1,278,1,228,1,292,1,330,1,326,1;8;220;FLOAT;1;False;221;FLOAT;1;False;222;FLOAT;1;False;218;FLOAT;0;False;287;FLOAT;0;False;136;FLOAT;0;False;279;FLOAT;0.1;False;342;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;141,-99;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;LanguageFlag;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;6;0;7;0
WireConnection;8;0;5;0
WireConnection;8;1;6;0
WireConnection;2;220;3;0
WireConnection;2;222;4;0
WireConnection;2;279;8;0
WireConnection;0;0;1;0
WireConnection;0;11;2;0
ASEEND*/
//CHKSM=73C0295C9269E86F56DDE4D4A1F9ED4990CF0607