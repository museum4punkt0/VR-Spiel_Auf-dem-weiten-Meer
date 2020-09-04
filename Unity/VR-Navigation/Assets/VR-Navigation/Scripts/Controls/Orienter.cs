using UnityEngine;
using Valve.VR.InteractionSystem;

namespace HumboldtForum.Controls
{
    [ExecuteInEditMode]
    public class Orienter : MonoBehaviour
    {
        public Interactable Dragger => dragger;

        [SerializeField] Interactable dragger = default;
        [SerializeField] Transform rotator = default;

        [SerializeField] int minX = -90;
        [SerializeField] int maxX = 90;
        [SerializeField] int minZ = -90;
        [SerializeField] int maxZ = 90;

        void Awake()
        {
            dragger.onAttachedToHand += OnDraggerPickedUp;
            dragger.onDetachedFromHand += OnDraggerReleased;
        }

        private void OnDraggerReleased(Hand hand)
        {
            enabled = false;
        }

        void OnDestroy()
        {
            dragger.onAttachedToHand -= OnDraggerPickedUp;
            dragger.onDetachedFromHand -= OnDraggerReleased;
        }

        private void OnDraggerPickedUp(Hand hand)
        {
            enabled = true;
        }

        // Update is called once per frame
        void Update()
        {
            if (dragger && rotator)
            {
                Vector3 local = transform.InverseTransformPoint(dragger.transform.position);

                float angleRight = Vector3.Angle(Vector3.right, local);
                float angleForward = Vector3.Angle(Vector3.forward, local);

                float x = Mathf.Clamp(90 - angleForward, minX, maxX);
                float z = Mathf.Clamp(angleRight - 90, minZ, maxZ);
                rotator.transform.localRotation = Quaternion.Euler(x, 0, z);
            }
        }
    }
}