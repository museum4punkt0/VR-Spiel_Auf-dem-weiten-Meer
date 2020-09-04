using UnityEngine;
using UnityEngine.UI;
using DG.Tweening;
using UnityEngine.Serialization;

namespace HumboldtForum.VR
{
    public class GazeInput : MonoBehaviour
    {
        [SerializeField] float sightlength = 500.0f;
        [SerializeField] LayerMask layerMask = default;
        [SerializeField] float targetDistance = 2f;
        [SerializeField] Canvas canvas = default;
        [SerializeField, FormerlySerializedAs("targetImages")] RectTransform targetsContainer = default;
        [SerializeField] Image timerImage = default;

        private GazeButton activeButton;
        private float currentTargetDistance;

        public Image TimerImage { get => timerImage; }

        void Awake()
        {
            if (timerImage)
            {
                timerImage.fillAmount = 0;
            }
        }

        void FixedUpdate()
        {
            Ray raydirection = new Ray(transform.position, transform.forward);

            float newHitDistance = targetDistance;

            if (Physics.Raycast(raydirection, out RaycastHit lastHit, sightlength, layerMask))
            {
                newHitDistance = lastHit.distance - .05f;
                GazeButton gazeButton = lastHit.collider.GetComponent<GazeButton>();
                if (gazeButton != activeButton)
                {
                    if (activeButton)
                    {
                        GazeLost();
                    }
                    else
                    {
                        gazeButton.GazeEnter(this);
                        activeButton = gazeButton;
                    }
                }
            }
            else
            {
                GazeLost();
            }

            if (activeButton)
            {
                targetsContainer.DOSizeDelta(new Vector2(20, 20), .3f);
            }
            else
            {
                targetsContainer.DOSizeDelta(new Vector2(15, 15), .3f);
            }

            if (currentTargetDistance != newHitDistance)
            {
                DOTween.Kill(this);
                DOVirtual.Float(canvas.planeDistance, newHitDistance, .1f, (f) =>
                 {
                     canvas.planeDistance = f;
                 }).SetEase(Ease.Linear).SetId(this);
                currentTargetDistance = newHitDistance;
            }
        }

        void OnTransformParentChanged()
        {
            // reset position
            transform.localPosition = Vector3.zero;
            transform.localRotation = Quaternion.identity;
            transform.localScale = Vector3.one;
            // and link canvas to current camera
            Camera camera = transform.GetComponentInParent<Camera>();
            canvas.worldCamera = camera;
        }

        private void GazeLost()
        {
            if (activeButton)
            {
                activeButton.GazeExit();
                activeButton = null;
            }
        }

        void OnDisable()
        {
            GazeLost();
        }

        void OnDestroy()
        {
            DOTween.Kill(this);
            DOTween.Kill(targetsContainer);
        }
    }
}