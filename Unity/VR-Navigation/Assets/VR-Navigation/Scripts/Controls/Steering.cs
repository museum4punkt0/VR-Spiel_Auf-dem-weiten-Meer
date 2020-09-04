using UnityEngine;
using DG.Tweening;

namespace HumboldtForum.Controls
{
    [RequireComponent(typeof(BoatAlignNormal))]
    public class Steering : MonoBehaviour
    {
        [SerializeField] Transform paddle = default;
        [SerializeField] float neutral = default;
        [SerializeField] float modifier = .1f;

        private BoatAlignNormal boatAligner;
        public float Drift = 0f;

        void Awake()
        {
            boatAligner = GetComponent<BoatAlignNormal>();
        }

        void Update()
        {
            if (paddle)
            {
                float paddleAngle = paddle.transform.localRotation.eulerAngles.z - neutral;
                if (paddleAngle > 180f)
                {
                    paddleAngle -= 360f;
                }
                boatAligner.SteerBias = (paddleAngle * modifier * Mathf.Max(.1f, boatAligner.ThrottleBias)) + Drift;
            }
        }

        public void ResetToNeutral()
        {
            Vector3 anglesNow = paddle.transform.localRotation.eulerAngles;
            if (anglesNow.z > 180)
            {
                anglesNow.z -= 360;
            }
            DOVirtual.Float(anglesNow.z, neutral, .3f, (f) =>
            {
                paddle.transform.localEulerAngles = new Vector3(anglesNow.x, anglesNow.y, f);
            });
        }
    }
}