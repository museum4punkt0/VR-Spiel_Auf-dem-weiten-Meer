// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Eyes"
{
	Properties
	{
		_BlinkSpeedA("BlinkSpeedA", Float) = 1.67
		_BlinkSpeedB("BlinkSpeedB", Float) = 1.67
		_OffSetVal("OffSetVal", Float) = 1.67
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
			half filler;
		};

		uniform float _OffSetVal;
		uniform float _BlinkSpeedA;
		uniform float _BlinkSpeedB;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float mulTime12 = _Time.y * _BlinkSpeedA;
			float mulTime21 = _Time.y * _BlinkSpeedB;
			float ifLocalVar23 = 0;
			if( abs( round( sin( mulTime12 ) ) ) > abs( round( sin( mulTime21 ) ) ) )
				ifLocalVar23 = 0.0;
			else if( abs( round( sin( mulTime12 ) ) ) < abs( round( sin( mulTime21 ) ) ) )
				ifLocalVar23 = 1.0;
			float3 ase_vertexNormal = v.normal.xyz;
			v.vertex.xyz += ( _OffSetVal * ( (0.2 + (ifLocalVar23 - 0.0) * (1.0 - 0.2) / (1.0 - 0.0)) * ase_vertexNormal ) );
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float4 color1 = IsGammaSpace() ? float4(0,0,0,0) : float4(0,0,0,0);
			o.Albedo = color1.rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17600
150;388;2000;1196;1540.633;275.3568;1.21;True;True
Node;AmplifyShaderEditor.RangedFloatNode;22;-1171.087,176.254;Inherit;False;Property;_BlinkSpeedB;BlinkSpeedB;1;0;Create;True;0;0;False;0;1.67;0.61;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-1095.499,-91.76374;Inherit;False;Property;_BlinkSpeedA;BlinkSpeedA;0;0;Create;True;0;0;False;0;1.67;2.33;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;21;-948.5146,167.3032;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;12;-872.9266,-100.7145;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;19;-758.5691,170.065;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;11;-682.9811,-97.95273;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RoundOpNode;20;-611.4739,290.7005;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RoundOpNode;16;-551.6162,67.45274;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;10;-431.04,210.8799;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-808.5836,483.3131;Inherit;False;Constant;_Float1;Float 0;3;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-752.9235,399.8231;Inherit;False;Constant;_Float0;Float 0;3;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;24;-479.4636,326.0132;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ConditionalIfNode;23;-305.2236,363.5234;Inherit;False;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;17;-66.26553,252.6587;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0.2;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;5;-682,620.5;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;14;178.3032,837.6249;Inherit;False;Property;_OffSetVal;OffSetVal;2;0;Create;True;0;0;False;0;1.67;-0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-207,638.5;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;10,480.5;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;1;-293,-69.5;Inherit;False;Constant;_Color0;Color 0;0;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;18;-696,812.5;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;316.7107,-31;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Eyes;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;21;0;22;0
WireConnection;12;0;6;0
WireConnection;19;0;21;0
WireConnection;11;0;12;0
WireConnection;20;0;19;0
WireConnection;16;0;11;0
WireConnection;10;0;16;0
WireConnection;24;0;20;0
WireConnection;23;0;10;0
WireConnection;23;1;24;0
WireConnection;23;2;25;0
WireConnection;23;4;26;0
WireConnection;17;0;23;0
WireConnection;7;0;17;0
WireConnection;7;1;5;0
WireConnection;15;0;14;0
WireConnection;15;1;7;0
WireConnection;0;0;1;0
WireConnection;0;11;15;0
ASEEND*/
//CHKSM=BE2B584848FF89620092CADBC7746F0DC02CF6CA