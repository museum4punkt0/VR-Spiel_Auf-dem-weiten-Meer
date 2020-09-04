using IJsfontein.GameStates;

namespace HumboldtForum.GameStates
{
    public class GameState : AbstractGameState
    {
        new public readonly GameContext context;
        public GameState(GameContext context, HumboldtForum.Main.LayerName uiLayer) : base(context, (int)uiLayer)
        {
            this.context = context;
        }
    }
}