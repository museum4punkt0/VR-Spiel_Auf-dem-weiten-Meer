using System;
using UnityEngine;

namespace HumboldtForum.Shaders
{
    public class ShaderGlobalsInitializer : MonoBehaviour
    {
        [SerializeField] ShaderSetting[] globals = default;

        void Awake()
        {
            foreach (ShaderSetting setting in globals)
            {
                Vector4 d = setting.Values;
                PlayableShaderGlobalConfig.ValueType tp = setting.ShaderGlobalConfig.valueType;
                string key = setting.ShaderGlobalConfig.shaderParamName;
                switch (tp)
                {
                    case PlayableShaderGlobalConfig.ValueType.Float:
                        {
                            Shader.SetGlobalFloat(key, d.x);
                            break;
                        }
                    case PlayableShaderGlobalConfig.ValueType.Int:
                        {
                            Shader.SetGlobalInt(key, (int)d.x);
                            break;
                        }
                    default:
                        {
                            Shader.SetGlobalVector(key, d);
                            break;
                        }
                }
            }
        }
    }

    [Serializable]
    public class ShaderSetting
    {
        [SerializeField] PlayableShaderGlobalConfig shaderGlobalConfig = default;
        [SerializeField] Vector4 values = default;

        public PlayableShaderGlobalConfig ShaderGlobalConfig => shaderGlobalConfig;
        public Vector4 Values => values;
    }
}