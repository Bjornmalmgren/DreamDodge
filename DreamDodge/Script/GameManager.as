class AGameManager : AActor{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent Root;

    UPROPERTY()
    FLinearColor Nightmare = FLinearColor(0.00, 0.00, 0.00);
    UPROPERTY()
    FLinearColor Dream = FLinearColor(0.875,0.127,0.568,1);
    UPROPERTY()
    FLinearColor Normal = FLinearColor(0.00,0.127,0.568,1);
    UPROPERTY()
    TArray<USoundWave> DreamMusic;
    UPROPERTY()
    TArray<USoundWave> NightmareMusic;

    AEnviormentManager EnviormentManager;
    AJesterBoss Boss;
    APlayer Player;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        TArray<AEnviormentManager> Emanagers;
        GetAllActorsOfClass(AEnviormentManager, Emanagers);
        EnviormentManager = Emanagers[0];

        TArray<AJesterBoss> Jesters;
        GetAllActorsOfClass(AJesterBoss, Jesters);
        Boss = Jesters[0];

        TArray<APlayer> PLayers;
        GetAllActorsOfClass(APlayer, PLayers);
        Player = PLayers[0];
    }

    UFUNCTION()
    void SwapDimensions(EDimension NewDimension){
        EnviormentManager.HidePlatforms(NewDimension);
        Boss.SwapDimensions(NewDimension);
    }

    UFUNCTION()
    void PlayerDied(){
        Player.SetActorTickEnabled(false);
        //Boss.SetActorTickEnabled(false);
        //EnviormentManager.SetActorTickEnabled(false);

        //lose
        Player.EndScreen.SetVisibility(ESlateVisibility::Visible);
        Player.EndScreen.Message.Text = Text::Conv_StringToText("You Died");
    }

    UFUNCTION()
    void BossDied(){
        Player.SetActorTickEnabled(false);
        //Boss.SetActorTickEnabled(false);
        //EnviormentManager.SetActorTickEnabled(false);

        //win
        Player.EndScreen.SetVisibility(ESlateVisibility::Visible);
        Player.EndScreen.Message.Text = Text::Conv_StringToText("You Won");
    }
}