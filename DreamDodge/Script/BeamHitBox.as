class ABeamHitBox : AActor{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent Root;
    UPROPERTY(DefaultComponent)
    UBoxComponent HitBox;

    UFUNCTION()
    void Destroy(){
        DestroyActor();
    }
}