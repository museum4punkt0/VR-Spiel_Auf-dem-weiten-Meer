using DG.Tweening;
using IJsfontein.GameStates;
using UnityEngine;
using Valve.VR;

namespace HumboldtForum.GameStates
{
    public class GameStateInit : GameState
    {
        const Assignments skipToAssignment = Assignments.NO_CHEAT;

        public GameStateInit(GameContext context) : base(context, HumboldtForum.Main.LayerName.Init)
        {
        }

        enum Assignments
        {
            NO_CHEAT = -1,
            SUN = 0,
            STARS = 1,
            CLOUDS = 2,
            BIRDS = 3
        }

        override public void Activate(AbstractGameState previousState)
        {
            base.Activate(previousState);
            const float fadeDuration = 1f;
            SteamVR_Fade.Start(Color.black, 0);

            DOVirtual.DelayedCall(1 + fadeDuration,
                () =>
                {
                    SteamVR_Fade.Start(Color.clear, fadeDuration);

                    if (Application.isEditor && skipToAssignment != Assignments.NO_CHEAT)
                    {
                        context.SetSailToAssignmentState((int)skipToAssignment, 1f);
                    }
                    else
                    {
                        context.StateMachine.SetState(new GameStateNavigatorIntro(context));
                    }
                });
        }
    }
}