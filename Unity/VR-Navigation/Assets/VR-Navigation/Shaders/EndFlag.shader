// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "EndFlag"
{
	Properties
	{
		_vAmpVal("vAmpVal", Range( 0 , 1)) = 0.2706771
		_vScaleVal("vScaleVal", Range( 0 , 100)) = 0
		_vSpeedVal("vSpeedVal", Range( 0 , 3)) = 0.2186255
		_PaintedFabricTex("PaintedFabricTex", 2D) = "white" {}
		_FabricTex("FabricTex", 2D) = "white" {}
		_SunAchievementTex("SunAchievementTex", 2D) = "white" {}
		_SunFlagVal("SunFlagVal", Range( 0 , 1)) = 0
		_StarsAchievementTex("StarsAchievementTex", 2D) = "white" {}
		_StarsFlagVal("StarsFlagVal", Range( 0 , 1)) = 0
		_CloudsAchievementTex("CloudsAchievementTex", 2D) = "white" {}
		_CloudsFlagVal("CloudsFlagVal", Range( 0 , 1)) = 0
		_BirdsAchievementTex("BirdsAchievementTex", 2D) = "white" {}
		_BirdsFlagVal("BirdsFlagVal", Range( 0 , 1)) = 0
		[Toggle]_ToggleSun("Toggle Sun", Float) = 1
		[Toggle]_ToggleStars("Toggle Stars", Float) = 1
		[Toggle]_ToggleClouds("Toggle Clouds", Float) = 1
		[Toggle]_ToggleBirds("Toggle Birds", Float) = 1
		_VertexMovemenMask("VertexMovemenMask", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
		
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
		uniform float _vScaleVal;
		uniform half ADS_GlobalSpeed;
		uniform float _vSpeedVal;
		uniform half ADS_GlobalAmplitude;
		uniform float _vAmpVal;
		uniform half3 ADS_GlobalDirection;
		uniform sampler2D _VertexMovemenMask;
		uniform float4 _VertexMovemenMask_ST;
		uniform sampler2D _FabricTex;
		uniform float4 _FabricTex_ST;
		uniform sampler2D _PaintedFabricTex;
		uniform float4 _PaintedFabricTex_ST;
		uniform sampler2D _BirdsAchievementTex;
		uniform float4 _BirdsAchievementTex_ST;
		uniform float _ToggleBirds;
		uniform float _BirdsFlagVal;
		uniform float gBirdsFlagGraphic;
		uniform sampler2D _SunAchievementTex;
		uniform float4 _SunAchievementTex_ST;
		uniform float _ToggleSun;
		uniform float _SunFlagVal;
		uniform float gSunFlagGraphic;
		uniform sampler2D _StarsAchievementTex;
		uniform float4 _StarsAchievementTex_ST;
		uniform float _ToggleStars;
		uniform float _StarsFlagVal;
		uniform float gStarsFlagGraphic;
		uniform sampler2D _CloudsAchievementTex;
		uniform float4 _CloudsAchievementTex_ST;
		uniform float _ToggleClouds;
		uniform float _CloudsFlagVal;
		uniform float gCloudsFlagGraphic;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			half MotionScale60_g288 = ( ADS_GlobalScale * _vScaleVal );
			half MotionSpeed62_g288 = ( ADS_GlobalSpeed * _vSpeedVal );
			float mulTime90_g288 = _Time.y * MotionSpeed62_g288;
			float2 temp_output_95_0_g288 = ( ( (ase_worldPos).xz * MotionScale60_g288 ) + mulTime90_g288 );
			half MotionVariation269_g288 = 1.0;
			half MotionlAmplitude58_g288 = ( ADS_GlobalAmplitude * _vAmpVal );
			float2 temp_output_92_0_g288 = ( sin( ( temp_output_95_0_g288 + MotionVariation269_g288 ) ) * MotionlAmplitude58_g288 );
			half3 GlobalDirection349_g288 = ADS_GlobalDirection;
			float3 break339_g288 = mul( unity_WorldToObject, float4( GlobalDirection349_g288 , 0.0 ) ).xyz;
			float2 appendResult340_g288 = (float2(break339_g288.x , break339_g288.z));
			half2 MotionDirection59_g288 = appendResult340_g288;
			half MotionMask137_g288 = 1.0;
			float2 temp_output_94_0_g288 = ( ( temp_output_92_0_g288 * MotionDirection59_g288 ) * MotionMask137_g288 );
			float2 break311_g288 = temp_output_94_0_g288;
			float3 appendResult308_g288 = (float3(break311_g288.x , 0.0 , break311_g288.y));
			float3 temp_output_40_0 = appendResult308_g288;
			float2 uv_VertexMovemenMask = v.texcoord * _VertexMovemenMask_ST.xy + _VertexMovemenMask_ST.zw;
			float3 lerpResult45 = lerp( temp_output_40_0 , float3( 0,0,0 ) , ( 1.0 - tex2Dlod( _VertexMovemenMask, float4( uv_VertexMovemenMask, 0, 0.0) ).r ));
			v.vertex.xyz += lerpResult45;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_FabricTex = i.uv_texcoord * _FabricTex_ST.xy + _FabricTex_ST.zw;
			float2 uv_PaintedFabricTex = i.uv_texcoord * _PaintedFabricTex_ST.xy + _PaintedFabricTex_ST.zw;
			float2 uv_BirdsAchievementTex = i.uv_texcoord * _BirdsAchievementTex_ST.xy + _BirdsAchievementTex_ST.zw;
			float lerpResult29 = lerp( 0.0 , tex2D( _BirdsAchievementTex, uv_BirdsAchievementTex ).r , lerp(_BirdsFlagVal,gBirdsFlagGraphic,_ToggleBirds));
			float2 uv_SunAchievementTex = i.uv_texcoord * _SunAchievementTex_ST.xy + _SunAchievementTex_ST.zw;
			float lerpResult31 = lerp( 0.0 , tex2D( _SunAchievementTex, uv_SunAchievementTex ).r , lerp(_SunFlagVal,gSunFlagGraphic,_ToggleSun));
			float2 uv_StarsAchievementTex = i.uv_texcoord * _StarsAchievementTex_ST.xy + _StarsAchievementTex_ST.zw;
			float lerpResult28 = lerp( 0.0 , tex2D( _StarsAchievementTex, uv_StarsAchievementTex ).r , lerp(_StarsFlagVal,gStarsFlagGraphic,_ToggleStars));
			float2 uv_CloudsAchievementTex = i.uv_texcoord * _CloudsAchievementTex_ST.xy + _CloudsAchievementTex_ST.zw;
			float lerpResult30 = lerp( 0.0 , tex2D( _CloudsAchievementTex, uv_CloudsAchievementTex ).r , lerp(_CloudsFlagVal,gCloudsFlagGraphic,_ToggleClouds));
			float4 lerpResult5 = lerp( tex2D( _FabricTex, uv_FabricTex ) , tex2D( _PaintedFabricTex, uv_PaintedFabricTex ) , ( lerpResult29 + lerpResult31 + lerpResult28 + lerpResult30 ));
			o.Emission = lerpResult5.rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16900
78;711;2005;1068;2307.926;-270.5155;1.86597;True;True
Node;AmplifyShaderEditor.CommentaryNode;6;-1667.885,-761.3244;Float;False;1021.554;1489.928;// AchievementGraphic;21;33;31;30;29;28;26;25;24;23;21;20;19;18;16;15;14;13;12;9;8;7;// AchievementGraphic;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-1574.799,614.6589;Float;False;Property;_BirdsFlagVal;BirdsFlagVal;16;0;Create;True;0;0;False;0;0;0.958;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-1577.55,287.989;Float;False;Property;_CloudsFlagVal;CloudsFlagVal;14;0;Create;True;0;0;False;0;0;0.921;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-1278.006,0.9509277;Float;False;Global;gStarsFlagGraphic;gStarsFlagGraphic;29;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-1640.433,-186.0077;Float;False;Global;gSunFlagGraphic;gSunFlagGraphic;29;0;Create;True;0;0;False;0;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-1261.086,700.0348;Float;False;Global;gBirdsFlagGraphic;gBirdsFlagGraphic;29;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-1596.952,-2.364014;Float;False;Property;_StarsFlagVal;StarsFlagVal;12;0;Create;True;0;0;False;0;0;0.93;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-1626.613,-384.2263;Float;False;Property;_SunFlagVal;SunFlagVal;10;0;Create;True;0;0;False;0;0;0.934;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-1268.787,328.239;Float;False;Global;gCloudsFlagGraphic;gCloudsFlagGraphic;29;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;26;-1190.489,516.5909;Float;False;Property;_ToggleBirds;Toggle Birds;20;0;Create;True;0;0;False;0;1;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;23;-1608.171,-189.683;Float;True;Property;_StarsAchievementTex;StarsAchievementTex;11;0;Create;True;0;0;False;0;None;2d5c63a8e692c48ccb45b71b7aee5c9d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;25;-1603.854,383.2939;Float;True;Property;_BirdsAchievementTex;BirdsAchievementTex;15;0;Create;True;0;0;False;0;None;25e8088ffa5cf4e75982b6e19234ddb4;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ToggleSwitchNode;19;-1303.423,-109.078;Float;False;Property;_ToggleStars;Toggle Stars;18;0;Create;True;0;0;False;0;1;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;20;-1602.901,81.32703;Float;True;Property;_CloudsAchievementTex;CloudsAchievementTex;13;0;Create;True;0;0;False;0;None;5b6b99382de2a43efa89324d8cb782a6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ToggleSwitchNode;21;-1264.241,146.759;Float;False;Property;_ToggleClouds;Toggle Clouds;19;0;Create;True;0;0;False;0;1;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;18;-1322.978,-381.4467;Float;False;Property;_ToggleSun;Toggle Sun;17;0;Create;True;0;0;False;0;1;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;24;-1583.522,-647.7268;Float;True;Property;_SunAchievementTex;SunAchievementTex;9;0;Create;True;0;0;False;0;None;a35415242190c4b9b99e7b9369079833;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;37;-1621.906,1430.672;Float;False;Property;_vSpeedVal;vSpeedVal;6;0;Create;True;0;0;False;0;0.2186255;0.56;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-1650.59,1538.153;Float;False;Property;_vScaleVal;vScaleVal;5;0;Create;True;0;0;False;0;0;12.8;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-1635.959,1333.63;Float;False;Property;_vAmpVal;vAmpVal;4;0;Create;True;0;0;False;0;0.2706771;0.085;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;31;-1107.193,-532.1002;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;41;-995.8448,1863.849;Float;True;Property;_VertexMovemenMask;VertexMovemenMask;21;0;Create;True;0;0;False;0;None;ed24e7263a26f42348891dc173f46edb;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;29;-988.4481,413.176;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;30;-1007.875,97.70593;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;28;-1057.508,-162.954;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;40;-1162.585,1427.561;Float;False;ADS Motion Generic;0;;288;81cab27e2a487a645a4ff5eb3c63bd27;6,252,0,278,1,228,1,292,1,330,0,326,0;8;220;FLOAT;0;False;221;FLOAT;0;False;222;FLOAT;0;False;218;FLOAT;0;False;287;FLOAT;0;False;136;FLOAT;0;False;279;FLOAT;0;False;342;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;3;-464.4271,-749.3519;Float;True;Property;_PaintedFabricTex;PaintedFabricTex;7;0;Create;True;0;0;False;0;None;4aa5c549c923546cc85b19087cdf5fe1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;4;-410.5302,-1000.752;Float;True;Property;_FabricTex;FabricTex;8;0;Create;True;0;0;False;0;None;90c5d085db4514165808e3320f1de85b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;33;-872.2091,-701.1781;Float;True;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;42;-131.7234,1603.638;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;36;-1631.049,1144.432;Float;False;Property;_InflateVal;InflateVal;3;0;Create;True;0;0;False;0;0;-1.72;-2;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;5;-34.51315,-585.8661;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-795.011,1437.078;Float;False;Property;_flagsMovement;flagsMovement;2;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;44;-360.9432,1150.509;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;45;62.34755,1125.239;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalVertexDataNode;38;-1585.553,930.4571;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-1101.257,1100.766;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;285.6739,-196.5054;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;EndFlag;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;26;0;16;0
WireConnection;26;1;13;0
WireConnection;19;0;7;0
WireConnection;19;1;14;0
WireConnection;21;0;12;0
WireConnection;21;1;15;0
WireConnection;18;0;9;0
WireConnection;18;1;8;0
WireConnection;31;1;24;1
WireConnection;31;2;18;0
WireConnection;29;1;25;1
WireConnection;29;2;26;0
WireConnection;30;1;20;1
WireConnection;30;2;21;0
WireConnection;28;1;23;1
WireConnection;28;2;19;0
WireConnection;40;220;35;0
WireConnection;40;221;37;0
WireConnection;40;222;34;0
WireConnection;33;0;29;0
WireConnection;33;1;31;0
WireConnection;33;2;28;0
WireConnection;33;3;30;0
WireConnection;42;0;41;1
WireConnection;5;0;4;0
WireConnection;5;1;3;0
WireConnection;5;2;33;0
WireConnection;44;0;40;0
WireConnection;44;1;39;0
WireConnection;44;2;43;0
WireConnection;45;0;40;0
WireConnection;45;2;42;0
WireConnection;39;0;38;0
WireConnection;39;1;36;0
WireConnection;0;2;5;0
WireConnection;0;11;45;0
ASEEND*/
//CHKSM=FEBF291E71027AE14CAC1D43E6719695837681B5