class ABeamHitBox : AActor{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent Root;
    UPROPERTY(DefaultComponent)
    UBoxComponent HitBox;

    UFUNCTION()
    void Destroy(){
        DestroyActor();
    }

    UFUNCTION(BlueprintOverride)
    void ActorBeginOverlap(AActor OtherActor)
    {
        if(OtherActor.ActorHasTag(n"Boss")){
            Cast<AJesterBoss>(OtherActor).TakeDamage(7);
        }
    }
}