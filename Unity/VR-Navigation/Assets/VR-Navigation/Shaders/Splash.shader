// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SkirtSplash"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.92
		_SplashShapB("SplashShapB", 2D) = "white" {}
		_Mask("Mask", 2D) = "white" {}
		_SplashShapeA("SplashShapeA", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,0)
		_Min("Min", Range( 0 , 1)) = 0
		_Max("Max", Range( 0 , 1)) = 0
		_TimeScale("TimeScale", Float) = 0
		_noiseUV("noiseUV", Vector) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Off
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float4 _Color;
		uniform float _Min;
		uniform float _Max;
		uniform sampler2D _SplashShapeA;
		uniform sampler2D _SplashShapB;
		uniform float2 _noiseUV;
		uniform float _TimeScale;
		uniform sampler2D _Mask;
		uniform float4 _Mask_ST;
		uniform float _Cutoff = 0.92;


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


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Emission = _Color.rgb;
			o.Alpha = 1;
			float2 panner62 = ( 2.0 * _Time.y * float2( 0,-1 ) + i.uv_texcoord);
			float2 panner69 = ( 2.0 * _Time.y * float2( 0,-1 ) + i.uv_texcoord);
			float mulTime60 = _Time.y * _TimeScale;
			float2 temp_cast_1 = (mulTime60).xx;
			float2 uv_TexCoord46 = i.uv_texcoord * _noiseUV + temp_cast_1;
			float simplePerlin2D40 = snoise( uv_TexCoord46 );
			float2 uv_Mask = i.uv_texcoord * _Mask_ST.xy + _Mask_ST.zw;
			float smoothstepResult37 = smoothstep( _Min , _Max , ( ( ( tex2D( _SplashShapeA, panner62 ).r * tex2D( _SplashShapB, panner69 ).r * simplePerlin2D40 ) + simplePerlin2D40 ) * tex2D( _Mask, uv_Mask ).r ));
			clip( smoothstepResult37 - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16900
90.4;192;1731;899;930.3278;552.0551;1.241962;True;True
Node;AmplifyShaderEditor.CommentaryNode;67;-1534.776,-540.9676;Float;False;453.4089;576.7515;Comment;3;63;66;62;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-1435.138,651.452;Float;False;Property;_TimeScale;TimeScale;7;0;Create;True;0;0;False;0;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;68;-2048.139,-205.0718;Float;False;453.4089;576.7515;Comment;3;69;70;71;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector2Node;74;-1227.025,320.0193;Float;False;Property;_noiseUV;noiseUV;10;0;Create;True;0;0;False;0;0,0;1,-1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleTimeNode;60;-1153.465,592.2631;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;63;-1484.776,-490.9676;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;70;-1990.666,-153.1497;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;62;-1284.367,-368.8997;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,-1;False;1;FLOAT;2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;46;-890.9316,503.9836;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;0.2,0.2;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;69;-1790.257,-31.08187;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,-1;False;1;FLOAT;2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;13;-823.0363,-158.3877;Float;True;Property;_SplashShapeA;SplashShapeA;3;0;Create;True;0;0;False;0;None;f6dea48756d27438692749c46ecc6cd0;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;10;-838.0677,114.2528;Float;True;Property;_SplashShapB;SplashShapB;1;0;Create;True;0;0;False;0;None;5b2f82e1fae05403f99e836246425bdf;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NoiseGeneratorNode;40;-623.0424,487.0794;Float;False;Simplex2D;1;0;FLOAT2;2,2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;-396.3952,-18.45305;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;73;-214.7898,19.11542;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;65;-290.3378,393.8733;Float;True;Property;_Mask;Mask;2;0;Create;True;0;0;False;0;None;f5893d64f30584979ba6e06f4ad5ea41;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;39;-291.7366,-199.7699;Float;False;Property;_Max;Max;6;0;Create;True;0;0;False;0;0;0.537;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-167.1654,212.9311;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-282.4706,-290.6076;Float;False;Property;_Min;Min;5;0;Create;True;0;0;False;0;0;0.105;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;37;74.65353,146.7619;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;66;-1415.366,-79.21606;Float;False;Property;_speed;speed;8;0;Create;True;0;0;False;0;0;2.72;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-1921.256,258.6018;Float;False;Property;_Float0;Float 0;9;0;Create;True;0;0;False;0;0;3.21;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;15;-159.0566,-476.6949;Float;False;Property;_Color;Color;4;0;Create;True;0;0;False;0;1,1,1,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;61;435.4281,33.81597;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;SkirtSplash;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.92;True;True;0;True;TransparentCutout;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;60;0;56;0
WireConnection;62;0;63;0
WireConnection;46;0;74;0
WireConnection;46;1;60;0
WireConnection;69;0;70;0
WireConnection;13;1;62;0
WireConnection;10;1;69;0
WireConnection;40;0;46;0
WireConnection;72;0;13;1
WireConnection;72;1;10;1
WireConnection;72;2;40;0
WireConnection;73;0;72;0
WireConnection;73;1;40;0
WireConnection;64;0;73;0
WireConnection;64;1;65;1
WireConnection;37;0;64;0
WireConnection;37;1;38;0
WireConnection;37;2;39;0
WireConnection;61;2;15;0
WireConnection;61;10;37;0
ASEEND*/
//CHKSM=C8954385C3CB604D1CA861272B6A245E4B899A02