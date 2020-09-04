using DG.Tweening;
using IJsfontein.Properties;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.Serialization;

namespace IJsfontein.Audio
{
    public class AudioLibraryClipPlayer : MonoBehaviour
    {
        [HideInInspector] public string ClipGuid = default;// Editor handles this

        [SerializeField] AudioLibrary library = default;
        [SerializeField] AudioSource output = default;
        [SerializeField] bool useOneShotAudio = false;
        [SerializeField, Range(0, 1)] float volume = 1;
        [SerializeField] bool playOnEnable = false;
        [SerializeField, Conditional("useOneShotAudio", false)] bool stopOnDisable = false;
        [SerializeField, Conditional("playOnEnable", true)] float delayOnEnable = 0;
        [SerializeField] float fadeIn = 0;
        [SerializeField, Conditional("useOneShotAudio", false)] bool loop = false;
        [SerializeField, Conditional("loop", true)] float fadeOutLoopOnDisable = 0;

        public bool IsPlaying { get; private set; }
        public AudioLibrary Library => library;

        public UnityEvent Finished;

        void Awake()
        {
            if (!output)
            {
                output = GetComponent<AudioSource>();
                if (!output && !useOneShotAudio)
                {
                    output = gameObject.AddComponent<AudioSource>();
                    output.playOnAwake = false;
                    output.loop = false;
                }
            }
        }

        public void SetVolume(float volume)
        {
            if (output)
            {
                DOTween.Kill(output);
                output.volume = volume * this.volume;
            }
        }

        void OnEnable()
        {
            if (!gameObject.activeInHierarchy)
            {
                Debug.Log($"{this} enabled but not active!", this);
            }
            if (playOnEnable)
            {
                Play(delayOnEnable);
                // Debug.Log($"{this} play on enable", this);
            }
        }

        void Update()
        {
            if (IsPlaying)
            {
                if (!output.isPlaying)
                {
                    // Debug.Log($"{this}: audio stopped @ {output.time}/{output.clip.length}");
                    IsPlaying = false;
                    Finished?.Invoke();
                }
            }
        }

        public void Play()
        {
            Play(0);
        }

        public void Play(float delay = 0)
        {
            if (output)
            {
                DOTween.Kill(output); 
            }
            if (library)
            {
                AudioClip clip = default;
                clip = library.ClipForGuid(ClipGuid);
                if (clip)
                {
                    if (output)
                    {
                        if (output.clip != clip || !loop)
                        {
                            output.Stop();
                            output.clip = clip;
                        }
                        output.loop = loop;

                        if (fadeIn > 0)
                        {
                            if (!output.isPlaying)
                            {
                                output.volume = 0;
                            }
                            else
                            {
                                // still playing, probably because of fade out, so fade back in if necessary
                                DOTween.Kill(output);
                                output.DOFade(volume, fadeIn).SetId(output);
                            }
                        }
                        else
                        {
                            output.volume = volume;
                        }
                        if (!output.isPlaying)
                        {
                            if (output.gameObject.activeInHierarchy)
                            {
                                DOTween.Kill(output);
                                if (delay > 0)
                                {
                                    output.PlayDelayed(delay);
                                    output.DOFade(volume, fadeIn).SetId(output).SetDelay(delay);
                                }
                                else
                                {
                                    output.DOFade(volume, fadeIn).SetId(output);
                                    output.Play();
                                }
                                IsPlaying = true;
                            }
                            else
                            {
                                Debug.LogWarning($"{this}: Cannot play a disabled audiosource");
                            }
                        }
                    }
                    else
                    {
                        PlayClip(clip);
                    }
                }
            }
        }

        public void Play(string clipId)
        {
            SetClip(clipId);
            Play();
        }

        public void SetClip(string clipId)
        {
            string guid = Library.GuidForId(clipId);
            ClipGuid = guid;
        }

        void OnDisable()
        {
            if (stopOnDisable)
            {
                Stop();
            }
        }

        public void Stop()
        {
            if (output && output.isPlaying)
            {
                if (loop && fadeOutLoopOnDisable > 0)
                {
                    DOTween.Kill(output);
                    output.DOFade(0, fadeOutLoopOnDisable).SetId(output).OnComplete(() =>
                    {
                        if (output)
                        {
                            output.Stop();
                        }
                    });
                }
                else
                {
                    output.Stop();
                }
            }
            IsPlaying = false;
        }

        void OnValidate()
        {
            if (loop)
            {
                useOneShotAudio = false;
            }
            if (loop && fadeOutLoopOnDisable > 0)
            {
                stopOnDisable = true;
            }
        }

        void OnDestroy()
        {
            DOTween.Kill(output);
        }

        private static void PlayClip(AudioClip clip)
        {
            AudioSource audio = new GameObject(clip.name).AddComponent<AudioSource>();
            audio.PlayOneShot(clip);
            Destroy(audio.gameObject, clip.length);
        }
    }
}