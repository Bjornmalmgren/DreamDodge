class AGameManager : AActor{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent Root;

    UPROPERTY()
    FLinearColor Nightmare = FLinearColor(0.5,0,0,1);
    UPROPERTY()
    FLinearColor Dream = FLinearColor(0.875,0.127,0.568,1);
    UPROPERTY()
    FLinearColor Normal = FLinearColor(0.00,0.127,0.568,1);
}