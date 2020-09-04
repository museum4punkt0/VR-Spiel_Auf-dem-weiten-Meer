using System;
using DG.Tweening;
using HumboldtForum.Transforms;
using IJsfontein.LayerElements;
using UnityEngine;
using UnityEngine.Events;
using Valve.VR.InteractionSystem;

namespace HumboldtForum.Controls
{
    [RequireComponent(typeof(BoatAlignNormal), typeof(Steering), typeof(Rigidbody))]
    public class Boat : MonoBehaviour
    {
        public float Speed { get; set; }
        public bool IsPaddleEnabled => paddle.enabled;
        public MeshRenderer Sail => sail;

        public TransformFacing NoGoWarning => noGoWarning;

        [SerializeField] MeshRenderer sail = default;
        [SerializeField] TransformFacing noGoWarning = default;
        [SerializeField] ElementsLayerSwitcher sailAudio = default;

        public UnityEvent StartSteering;
        public UnityEvent StopSteering;

        private Orienter paddle;
        private BoatAlignNormal boat;
        private Steering steering;
        new private Rigidbody rigidbody;

        void Awake()
        {
            paddle = GetComponentInChildren<Orienter>();
            boat = GetComponent<BoatAlignNormal>();
            steering = GetComponent<Steering>();
            rigidbody = GetComponent<Rigidbody>();

            try
            {
                paddle.Dragger.onAttachedToHand += OnStartSteering;
                paddle.Dragger.onDetachedFromHand += OnStopSteering;
            }
            catch (Exception)
            {
                Debug.LogError($"{this} needs a child with an Orienter component", this);
            }

            StopSailing();
        }

        void Update()
        {
            float sailMovement = Mathf.Clamp01(1 - boat.ThrottleBias);
            sail.sharedMaterial.SetFloat("_gSailMovement", 1f - sailMovement);
        }

        internal void StartSailingWhenPaddleEnabled()
        {
            if (IsPaddleEnabled)
            {
                StartSailing();
            }
            else
            {
                Debug.Log($"{this}: paddle not enabled?", this);
            }
        }

        public void StartSailing()
        {
            // Debug.Log($"{this}: start sailing @speed {Speed}", this);
            TweenThrottleTo(Speed);
            if (Speed > 1)
            {
                sailAudio.ActivateLayer((int)HumboldtForum.Audio.Sail.LayerName.Fast);
            }
            else
            {
                sailAudio.ActivateLayer((int)HumboldtForum.Audio.Sail.LayerName.Slow);
            }
        }

        public bool IsSailing
        {
            get
            {
                return boat.ThrottleBias > 0;
            }
        }

        public void SetDrift(float value)
        {
            steering.Drift = value;
        }

        private void TweenThrottleTo(float newSpeed, float duration = 2)
        {
            DOTween.Kill(boat);
            DOVirtual.Float(boat.ThrottleBias, newSpeed, duration, (f) =>
            {
                boat.ThrottleBias = f;
            }).SetId(boat);
        }

        public void StartSailing(float speed)
        {
            Speed = speed;
            StartSailing();
        }

        public void StopSailing()
        {
            TweenThrottleTo(0f);
            sailAudio.ActivateLayer((int)HumboldtForum.Audio.Sail.LayerName.Flapping);
        }

        public void StopSailing(bool fast)
        {
            if (fast)
            {
                TweenThrottleTo(0, .1f);
            }
            else
            {
                StopSailing();
            }
        }

        public void Teleport(Transform to)
        {
            transform.position = to.position;
            transform.rotation = to.rotation;
        }

        public void BounceBack(float force)
        {
            Debug.Log($"{this} bounce back {force}", this);
            rigidbody.AddRelativeForce(Vector3.forward * -force);
        }

        private void OnStartSteering(Hand hand)
        {
            paddle.enabled = true; // this did not always work when setting it in unity editor
            StartSteering?.Invoke();
        }

        private void OnStopSteering(Hand hand)
        {
            paddle.enabled = false; // this did not always work when setting it in unity editor
            StopSteering?.Invoke();
        }

        void OnDestroy()
        {
            paddle.Dragger.onAttachedToHand -= OnStartSteering;
            paddle.Dragger.onDetachedFromHand -= OnStopSteering;
        }
    }
}