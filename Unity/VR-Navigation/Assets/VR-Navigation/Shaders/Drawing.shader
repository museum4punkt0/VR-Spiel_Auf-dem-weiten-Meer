// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Drawing"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
		[PerRendererData] _AlphaTex ("External Alpha", 2D) = "white" {}
		_TriplanarAlbedo("Triplanar Albedo", 2D) = "white" {}
		_Opacity("Opacity", Range( 0 , 1)) = 0
		_MinOld("MinOld", Range( 0 , 1)) = 0
		_MinNew("MinNew", Range( 0 , 1)) = 0
		_MaxOld("MaxOld", Range( 0 , 1)) = 0
		_MaxNew("MaxNew", Range( 0 , 1)) = 0
		_NoiseTiling("NoiseTiling", Vector) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
	}

	SubShader
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" "CanUseSpriteAtlas"="True" }

		Cull Off
		Lighting Off
		ZWrite Off
		Blend One OneMinusSrcAlpha
		
		
		Pass
		{
		CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile _ PIXELSNAP_ON
			#pragma multi_compile _ ETC1_EXTERNAL_ALPHA
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"


			struct appdata_t
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				float3 ase_normal : NORMAL;
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				float2 texcoord  : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
			};
			
			uniform fixed4 _Color;
			uniform float _EnableExternalAlpha;
			uniform sampler2D _MainTex;
			uniform sampler2D _AlphaTex;
			uniform float4 _MainTex_ST;
			uniform sampler2D _TriplanarAlbedo;
			uniform float2 _NoiseTiling;
			uniform float _MinOld;
			uniform float _MaxOld;
			uniform float _MinNew;
			uniform float _MaxNew;
			uniform float _Opacity;
			
			v2f vert( appdata_t IN  )
			{
				v2f OUT;
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
				UNITY_TRANSFER_INSTANCE_ID(IN, OUT);
				float3 ase_worldPos = mul(unity_ObjectToWorld, IN.vertex).xyz;
				OUT.ase_texcoord1.xyz = ase_worldPos;
				float3 ase_worldNormal = UnityObjectToWorldNormal(IN.ase_normal);
				OUT.ase_texcoord2.xyz = ase_worldNormal;
				
				
				//setting value to unused interpolator channels and avoid initialization warnings
				OUT.ase_texcoord1.w = 0;
				OUT.ase_texcoord2.w = 0;
				
				IN.vertex.xyz +=  float3(0,0,0) ; 
				OUT.vertex = UnityObjectToClipPos(IN.vertex);
				OUT.texcoord = IN.texcoord;
				OUT.color = IN.color * _Color;
				#ifdef PIXELSNAP_ON
				OUT.vertex = UnityPixelSnap (OUT.vertex);
				#endif

				return OUT;
			}

			fixed4 SampleSpriteTexture (float2 uv)
			{
				fixed4 color = tex2D (_MainTex, uv);

#if ETC1_EXTERNAL_ALPHA
				// get the color from an external texture (usecase: Alpha support for ETC1 on android)
				fixed4 alpha = tex2D (_AlphaTex, uv);
				color.a = lerp (color.a, alpha.r, _EnableExternalAlpha);
#endif //ETC1_EXTERNAL_ALPHA

				return color;
			}
			
			fixed4 frag(v2f IN  ) : SV_Target
			{
				float2 uv_MainTex = IN.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode1 = tex2D( _MainTex, uv_MainTex );
				float2 uv03 = IN.texcoord.xy * _NoiseTiling + float2( 0,0 );
				float2 panner6 = ( 0.3 * _Time.y * float2( 0.1,0 ) + uv03);
				float3 ase_worldPos = IN.ase_texcoord1.xyz;
				float2 appendResult81 = (float2(ase_worldPos.y , ase_worldPos.z));
				float3 ase_worldNormal = IN.ase_texcoord2.xyz;
				float3 temp_output_65_0 = abs( ase_worldNormal );
				float dotResult66 = dot( temp_output_65_0 , float3(1,1,1) );
				float3 BlendComponents68 = ( temp_output_65_0 / dotResult66 );
				float2 appendResult80 = (float2(ase_worldPos.x , ase_worldPos.z));
				float2 appendResult82 = (float2(ase_worldPos.x , ase_worldPos.y));
				float4 temp_cast_1 = (_MinOld).xxxx;
				float4 temp_cast_2 = (_MaxOld).xxxx;
				float4 temp_cast_3 = (_MinNew).xxxx;
				float4 temp_cast_4 = (_MaxNew).xxxx;
				float lerpResult4 = lerp( tex2DNode1.a , 0.0 , (temp_cast_3 + (( ( ( tex2D( _TriplanarAlbedo, ( panner6 + appendResult81 ) ) * BlendComponents68.x ) + ( tex2D( _TriplanarAlbedo, ( panner6 + appendResult80 ) ) * BlendComponents68.y ) ) + ( tex2D( _TriplanarAlbedo, ( panner6 + appendResult82 ) ) * BlendComponents68.z ) ) - temp_cast_1) * (temp_cast_4 - temp_cast_3) / (temp_cast_2 - temp_cast_1)).r);
				float4 appendResult5 = (float4(tex2DNode1.rgb , ( lerpResult4 * _Opacity )));
				
				fixed4 c = appendResult5;
				c.rgb *= c.a;
				return c;
			}
		ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=16900
597;569;1440;812;2113.076;65.73093;1.917226;True;True
Node;AmplifyShaderEditor.WorldNormalVector;62;-3432.622,2033.944;Float;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.AbsOpNode;65;-3000.622,2001.944;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;64;-3033.74,2182.393;Float;False;Constant;_Vector0;Vector 0;-1;0;Create;True;0;0;False;0;1,1,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;66;-2826.722,2068.341;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;67;-2664.622,2001.944;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;68;-2504.622,2001.944;Float;True;BlendComponents;1;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector2Node;57;-1512.235,683.0618;Float;False;Property;_NoiseTiling;NoiseTiling;6;0;Create;True;0;0;False;0;0,0;-2.9,-5.03;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.BreakToComponentsNode;70;-2200.622,2129.943;Float;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.BreakToComponentsNode;69;-2200.622,1841.944;Float;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.WireNode;72;-1928.622,1793.944;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;103;-2419.168,2399.537;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WireNode;71;-1928.622,2273.943;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;3;-1327.031,556.2729;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;82;-1711.379,2533.819;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;81;-1843.979,1567.497;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;80;-1603.587,1909.853;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;6;-1053.038,599.0806;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.1,0;False;1;FLOAT;0.3;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;78;-1896.622,2305.943;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;73;-1896.622,1761.944;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;74;-2200.622,1985.944;Float;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.WireNode;79;-1160.622,2305.943;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;98;-1634.104,1669.999;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;84;-1160.622,1761.944;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;83;-1160.622,2033.944;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;97;-1635.749,1459.237;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;99;-1538.297,2438.17;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;87;-1128.622,2001.944;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;85;-1128.622,1729.944;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;89;-1128.622,2273.943;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;90;-1420.898,2098.524;Float;True;Property;_TextureSample2;Texture Sample 2;0;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Instance;86;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;88;-1418.405,1828.505;Float;True;Property;_TextureSample1;Texture Sample 1;0;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Instance;86;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;86;-1413.322,1573.043;Float;True;Property;_TriplanarAlbedo;Triplanar Albedo;0;0;Create;True;0;0;False;0;None;80abf0a1b524241c2b45ab0cfa0b52d4;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;91;-1048.622,2065.943;Float;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;93;-1048.622,1825.944;Float;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;92;-1048.622,1553.944;Float;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;94;-792.6222,2017.944;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;95;-808.6223,1665.944;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-684.2608,457.2895;Float;False;Property;_MaxOld;MaxOld;4;0;Create;True;0;0;False;0;0;0.668;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;96;-552.6222,1921.944;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-635.0992,652.6082;Float;False;Property;_MaxNew;MaxNew;5;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-659.0157,373.5814;Float;False;Property;_MinOld;MinOld;2;0;Create;True;0;0;False;0;0;0.483;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;9;-744.2042,-163.0738;Float;False;0;0;_MainTex;Shader;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;13;-632.4418,562.2567;Float;False;Property;_MinNew;MinNew;3;0;Create;True;0;0;False;0;0;0.52;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-430.2626,-201.5;Float;True;Property;_Graphic;Graphic;0;0;Create;True;0;0;False;0;None;50db261a3cf144f8e8bf4109508ad906;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;10;-150.124,390.8546;Float;False;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0.46,0,0,0;False;3;COLOR;0.72,0,0,0;False;4;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;4;-23.70695,125.7134;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-222.1843,668.7737;Float;False;Property;_Opacity;Opacity;1;0;Create;True;0;0;False;0;0;0.802;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;150.3636,483.5103;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;5;302.5323,-106.1713;Float;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;666.549,13.93079;Float;False;True;2;Float;ASEMaterialInspector;0;6;Drawing;0f8ba0101102bb14ebf021ddadce9b49;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;2;True;3;1;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;True;2;False;-1;False;False;True;2;False;-1;False;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;0;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;0
WireConnection;65;0;62;0
WireConnection;66;0;65;0
WireConnection;66;1;64;0
WireConnection;67;0;65;0
WireConnection;67;1;66;0
WireConnection;68;0;67;0
WireConnection;70;0;68;0
WireConnection;69;0;68;0
WireConnection;72;0;69;0
WireConnection;71;0;70;2
WireConnection;3;0;57;0
WireConnection;82;0;103;1
WireConnection;82;1;103;2
WireConnection;81;0;103;2
WireConnection;81;1;103;3
WireConnection;80;0;103;1
WireConnection;80;1;103;3
WireConnection;6;0;3;0
WireConnection;78;0;71;0
WireConnection;73;0;72;0
WireConnection;74;0;68;0
WireConnection;79;0;78;0
WireConnection;98;0;6;0
WireConnection;98;1;80;0
WireConnection;84;0;73;0
WireConnection;83;0;74;1
WireConnection;97;0;6;0
WireConnection;97;1;81;0
WireConnection;99;0;6;0
WireConnection;99;1;82;0
WireConnection;87;0;83;0
WireConnection;85;0;84;0
WireConnection;89;0;79;0
WireConnection;90;1;99;0
WireConnection;88;1;98;0
WireConnection;86;1;97;0
WireConnection;91;0;90;0
WireConnection;91;1;89;0
WireConnection;93;0;88;0
WireConnection;93;1;87;0
WireConnection;92;0;86;0
WireConnection;92;1;85;0
WireConnection;94;0;91;0
WireConnection;95;0;92;0
WireConnection;95;1;93;0
WireConnection;96;0;95;0
WireConnection;96;1;94;0
WireConnection;1;0;9;0
WireConnection;10;0;96;0
WireConnection;10;1;11;0
WireConnection;10;2;12;0
WireConnection;10;3;13;0
WireConnection;10;4;14;0
WireConnection;4;0;1;4
WireConnection;4;2;10;0
WireConnection;8;0;4;0
WireConnection;8;1;7;0
WireConnection;5;0;1;0
WireConnection;5;3;8;0
WireConnection;0;0;5;0
ASEEND*/
//CHKSM=E482D13C7E3F99CF03A202618CD64A790DC73C02