//	CameraFacing.cs
//	original by Neil Carter (NCarter) http://wiki.unity3d.com/index.php?title=CameraFacingBillboard
using UnityEngine;

namespace HumboldtForum.Transforms
{
    // [ExecuteInEditMode]
    public class CameraFacing : MonoBehaviour
    {
        [Tooltip("Leave empty for main camera")]
        [SerializeField] Camera referenceCamera;

        void Awake()
        {
            // if no camera referenced, grab the main camera
            if (!referenceCamera)
            {
                referenceCamera = Camera.main;
            }
        }

        //Orient the camera after all movement is completed this frame to avoid jittering
        void LateUpdate()
        {
            // rotates the object relative to the camera
            Vector3 targetPos = referenceCamera.transform.position;
            transform.LookAt(targetPos);
        }
    }
}