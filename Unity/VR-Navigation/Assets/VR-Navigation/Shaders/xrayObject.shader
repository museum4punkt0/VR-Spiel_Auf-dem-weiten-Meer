// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "xrayObject"
{
	Properties
	{
		_XRayPower("XRayPower", Float) = 0
		_XRayScale("XRayScale", Float) = 0
		_XRayBias("XRayBias", Float) = 0
		_Color0("Color 0", Color) = (1,1,1,0)
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Standard alpha:fade keepalpha noshadow 
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
		};

		uniform float4 _Color0;
		uniform float _XRayBias;
		uniform float _XRayScale;
		uniform float _XRayPower;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Emission = _Color0.rgb;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNdotV4 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode4 = ( _XRayBias + _XRayScale * pow( 1.0 - fresnelNdotV4, _XRayPower ) );
			o.Alpha = fresnelNode4;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16900
29.6;217.6;1731;855;1287.752;653.2019;1.665373;True;True
Node;AmplifyShaderEditor.RangedFloatNode;1;-486.115,57.04855;Float;False;Property;_XRayPower;XRayPower;0;0;Create;True;0;0;False;0;0;3.45;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;2;-537.5798,-17.97202;Float;False;Property;_XRayScale;XRayScale;1;0;Create;True;0;0;False;0;0;0.27;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-524.4633,-123.1787;Float;False;Property;_XRayBias;XRayBias;2;0;Create;True;0;0;False;0;0;1.66;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;4;-289.4372,-123.6031;Float;True;Standard;TangentNormal;ViewDir;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;6;-52.04517,-410.0574;Float;False;Property;_Color0;Color 0;3;0;Create;True;0;0;False;0;1,1,1,0;0.4245282,0.2463064,0.2463064,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;487.9543,-129.8991;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;xrayObject;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;False;0;True;Transparent;;Transparent;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;4;1;3;0
WireConnection;4;2;2;0
WireConnection;4;3;1;0
WireConnection;0;2;6;0
WireConnection;0;9;4;0
ASEEND*/
//CHKSM=EB93F3D8D58FF3E6ED378F17FA76DA6297664E7A