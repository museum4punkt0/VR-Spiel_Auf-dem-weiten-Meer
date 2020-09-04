using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;
using DG.Tweening;
using UnityEngine.Serialization;
using System;

namespace HumboldtForum.VR
{
    [RequireComponent(typeof(GazeButton))]
    public class GazeTimer : MonoBehaviour
    {
        [SerializeField, FormerlySerializedAs("Duration")] float duration = default;
        [SerializeField, FormerlySerializedAs("FillImage")] Image fillImage = default;
        [SerializeField] bool useGazeInputTimerImage = true;
        [SerializeField] Sprite fillSprite = default;

        public UnityEvent OnTimerReset;

        private float startTime = 0;
        private GazeButton button;

        void Awake()
        {
            button = GetComponent<GazeButton>();
            button.OnGazeEnter.AddListener(OnGazeEnter);
            button.OnGazeExit.AddListener(OnGazeExit);
            fillImage.fillAmount = 0;
            if (useGazeInputTimerImage)
            {
                fillImage.enabled = false;
                fillImage = null;
                if (!fillSprite && fillSprite)
                {
                    fillSprite = fillImage.sprite;
                }
            }
        }

        private void OnGazeEnter(GazeInput gazeInput)
        {
            if (useGazeInputTimerImage && !fillImage)
            {
                fillImage = gazeInput.TimerImage;
                fillImage.sprite = fillSprite;
                fillImage.fillAmount = 0;
            }
            DOTween.Kill(fillImage);
            startTime = Time.time;
            if (fillImage.fillAmount > 0) // allow refill
            {
                startTime -= fillImage.fillAmount * duration;
            }
        }

        private void OnGazeExit()
        {
            startTime = 0;
            fillImage?.DOFillAmount(0, 1f).OnComplete(() =>
            {
                OnTimerReset?.Invoke();
                if (useGazeInputTimerImage)
                {
                    fillImage = null;
                }
            });
        }

        void Update()
        {
            if (startTime > 0)
            {
                float elapsed = Time.time - startTime;
                fillImage.fillAmount = elapsed / duration;
                if (elapsed >= duration)
                {
                    InvokeSelected();
                }
            }
        }

        private void InvokeSelected()
        {
            button.InvokeSelected();
            startTime = 0;
            fillImage.fillAmount = 0;
        }

        void OnDestroy()
        {
            DOTween.Kill(fillImage);
        }
    }
}