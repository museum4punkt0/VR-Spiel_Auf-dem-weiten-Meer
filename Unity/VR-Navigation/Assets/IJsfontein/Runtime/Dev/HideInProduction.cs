using UnityEngine;

namespace IJsfontein.Dev
{
    public class HideInProduction : MonoBehaviour
    {
        // Use this for initialization
#if PRODUCTION_BUILD
        void Start()
        {
            gameObject.SetActive(false);
        }
#endif
    }
}