// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "WindRibbon"
{
	Properties
	{
		_LightCol("LightCol", Color) = (0,0,0,0)
		_vAmpVal("vAmpVal", Float) = 0
		_vSpeedVal("vSpeedVal", Float) = 0
		_vScaleVal("vScaleVal", Float) = 0
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Off
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
		};

		uniform half ADS_GlobalScale;
		uniform float _vScaleVal;
		uniform half ADS_GlobalSpeed;
		uniform float _vSpeedVal;
		uniform half ADS_GlobalAmplitude;
		uniform float _vAmpVal;
		uniform half3 ADS_GlobalDirection;
		uniform float4 _LightCol;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			half MotionScale60_g278 = ( ADS_GlobalScale * _vScaleVal );
			half MotionSpeed62_g278 = ( ADS_GlobalSpeed * _vSpeedVal );
			float mulTime90_g278 = _Time.y * MotionSpeed62_g278;
			float2 temp_output_95_0_g278 = ( ( (ase_worldPos).xz * MotionScale60_g278 ) + mulTime90_g278 );
			half MotionVariation269_g278 = 1.0;
			half MotionlAmplitude58_g278 = ( ADS_GlobalAmplitude * _vAmpVal );
			float2 temp_output_92_0_g278 = ( sin( ( temp_output_95_0_g278 + MotionVariation269_g278 ) ) * MotionlAmplitude58_g278 );
			half3 GlobalDirection349_g278 = ADS_GlobalDirection;
			float3 break339_g278 = mul( unity_WorldToObject, float4( GlobalDirection349_g278 , 0.0 ) ).xyz;
			float2 appendResult340_g278 = (float2(break339_g278.x , break339_g278.z));
			half2 MotionDirection59_g278 = appendResult340_g278;
			half MotionMask137_g278 = v.color.r;
			float2 temp_output_94_0_g278 = ( ( temp_output_92_0_g278 * MotionDirection59_g278 ) * MotionMask137_g278 );
			float2 break311_g278 = temp_output_94_0_g278;
			float3 appendResult308_g278 = (float3(break311_g278.x , 0.0 , break311_g278.y));
			v.vertex.xyz += appendResult308_g278;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Albedo = _LightCol.rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16900
248;686.4;1731;883;1257.5;240.5;1;True;True
Node;AmplifyShaderEditor.VertexColorNode;4;-621.5,427;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;5;-857.5,145;Float;False;Property;_vAmpVal;vAmpVal;3;0;Create;True;0;0;False;0;0;0.11;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-868.5,244;Float;False;Property;_vSpeedVal;vSpeedVal;4;0;Create;True;0;0;False;0;0;0.12;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-860.5,345;Float;False;Property;_vScaleVal;vScaleVal;5;0;Create;True;0;0;False;0;0;86.46;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;2;-490.5,-72.5;Float;False;Property;_LightCol;LightCol;2;0;Create;True;0;0;False;0;0,0,0,0;1,0.0533333,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;1;-427.5,180.5;Float;False;ADS Motion Generic;0;;278;81cab27e2a487a645a4ff5eb3c63bd27;6,252,0,278,1,228,1,292,1,330,0,326,0;8;220;FLOAT;0.1;False;221;FLOAT;1;False;222;FLOAT;100;False;218;FLOAT;0;False;287;FLOAT;0;False;136;FLOAT;0;False;279;FLOAT;0;False;342;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;WindRibbon;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;1;220;5;0
WireConnection;1;221;6;0
WireConnection;1;222;7;0
WireConnection;1;136;4;1
WireConnection;0;0;2;0
WireConnection;0;11;1;0
ASEEND*/
//CHKSM=957BE37530FB83733568CE39B9E3B06DEC4B9A57