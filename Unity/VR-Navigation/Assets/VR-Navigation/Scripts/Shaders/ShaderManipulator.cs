using System.Collections;
using System.Collections.Generic;
using DG.Tweening;
using UnityEngine;

namespace HumboldtForum.Shaders
{
    [RequireComponent(typeof(Renderer))]
    public class ShaderManipulator : MonoBehaviour
    {
        new Renderer renderer;
        [SerializeField] string property = default;
        [SerializeField] float durationWhenTweening = default;

        void Awake()
        {
            renderer = GetComponent<Renderer>();
        }

        public void SetFloat(float f)
        {
            renderer.material.SetFloat(property, f);
        }

        public void TweenFloat(float f)
        {
            float current = renderer.material.GetFloat(property);
            DOVirtual.Float(current, f, durationWhenTweening, SetFloat).SetId(this);
        }

        void OnDestroy()
        {
            DOTween.Kill(this);
        }
    }
}