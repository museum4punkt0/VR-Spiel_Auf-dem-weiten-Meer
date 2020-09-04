using UnityEngine;

namespace HumboldtForum.Transforms
{
    [ExecuteInEditMode]
    public class TransformFacing : MonoBehaviour
    {
        [SerializeField] Transform referenceTransform = default;
        [SerializeField] bool executeInEditMode = true;
        [SerializeField] bool lockXRotation = false;
        [SerializeField] bool lockYRotation = false;
        [SerializeField] bool lockZRotation = false;

        private Vector3 originalRotation;

        public Transform Reference { get => referenceTransform; set => referenceTransform = value; }

        void OnEnable()
        {
            originalRotation = transform.rotation.eulerAngles;
        }

        //Orient the transform after all movement is completed this frame to avoid jittering
        void LateUpdate()
        {
            if (referenceTransform)
            {
                if (executeInEditMode || Application.isPlaying)
                {
                    // rotates the object relative to the camera
                    Vector3 targetPos = referenceTransform.position;
                    transform.LookAt(targetPos);
                    Vector3 angles = transform.rotation.eulerAngles;
                    if (lockXRotation)
                    {
                        angles.x = originalRotation.x;
                    }
                    if (lockYRotation)
                    {
                        angles.y = originalRotation.y;
                    }
                    if (lockZRotation)
                    {
                        angles.z = originalRotation.z;
                    }
                    transform.rotation = Quaternion.Euler(angles);
                }
            }
        }
    }
}