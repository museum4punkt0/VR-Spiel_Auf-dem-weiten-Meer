using UnityEngine;

[ExecuteInEditMode]
public class LockOnTransform : MonoBehaviour
{
    [SerializeField] Transform positionLock = default;
    [SerializeField] Transform rotationLock = default;
    [SerializeField] bool lockXRotation = false;
    [SerializeField] bool lockYRotation = false;
    [SerializeField] bool lockZRotation = false;

    [SerializeField] bool ExecuteInEditMode = default;

    private Vector3 originalRotation;

    public Transform PositionLock
    {
        get => positionLock;
        set => positionLock = value;

    }
    public Transform RotationLock
    {
        get => rotationLock;
        set => rotationLock = value;

    }

    void OnEnable()
    {
        originalRotation = transform.rotation.eulerAngles;
    }

    // Update is called once per frame
    void Update()
    {
        if (Application.isPlaying || ExecuteInEditMode)
        {
            if (positionLock)
            {
                transform.position = positionLock.position;
            }
            if (rotationLock)
            {
                Vector3 angles = rotationLock.rotation.eulerAngles;
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
