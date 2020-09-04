using HumboldtForum.Controls;
using HumboldtForum.GameStates;
using IJsfontein.Audio;
using IJsfontein.GameStates;
using IJsfontein.LayerElements;
using UnityEngine;
using UnityEngine.Audio;
using UnityEngine.Playables;

namespace HumboldtForum.Main
{
    [RequireComponent(typeof(ElementsLayerSwitcher))]
    public class Main : MonoBehaviour
    {
        [SerializeField] Boat boat = default;
        [SerializeField] PlayableDirector dayNightTimeline = default;
        [SerializeField] PlayableDirector achievementsTimeline = default;
        [SerializeField] AudioLibraryClipPlayer turtleAudioPlayer = default;
        [SerializeField] AudioMixer audioMixer = default;
        [SerializeField] Settings settings = default;


        private ElementsLayerSwitcher elementsLayerSwitcher = default;
        private GameContext context;

        void Start()
        {
            elementsLayerSwitcher = GetComponent<ElementsLayerSwitcher>();
            elementsLayerSwitcher.ActivateLayer((int)LayerName.Init);

            GameStateMachine stateMachine = new GameStateMachine();
            context = new GameContext(elementsLayerSwitcher, stateMachine);
            context.Boat = boat;
            context.DayNightTimeline = dayNightTimeline;
            context.SetAchievementsTimeline(achievementsTimeline);
            context.TurtleAudioPlayer = turtleAudioPlayer;
            context.AudioMixer = audioMixer;
            context.Settings = settings;

            stateMachine.SetState(new GameStateInit(context));
            context.StartGameTimer();
        }

        /// This method is triggered by a keyboard shortcut in the main scene
        public void LoadLanguageSelection()
        {
            context.LoadLanguageSelection(0, .3f);
        }

        /// This method is triggered by a keyboard shortcut in the main scene
        public void SailToNextAssigment()
        {
            AbstractGameState state = context.StateMachine.State;
            if (state is GameStateAssignment)
            {
                context.SetAssignmentCompleted();
            }
            context.SetSailToAssignmentState(context.AssignmentIndex + 1, 1.5f);
        }

        /// This method is triggered by a keyboard shortcut in the main scene
        public void TriggerTimeout()
        {
            context.TriggerTimeout();
        }

        /// This method is triggered by the headset change checker in the main scene.
        public void HeadsetStateChanged(bool isOn)
        {
            if (!isOn && context.StateMachine.State is GameStateParty)
            {
                LoadLanguageSelection();
            }
        }
    }
}