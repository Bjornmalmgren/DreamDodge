class UHealComponent : UActorComponent{
    UPROPERTY()
    int MaxHealth;
    UPROPERTY()
    int CurrentHealth;

    UFUNCTION()
    void SetHealth(int Amount){
        MaxHealth = Amount;
        CurrentHealth = Amount;
    }
    UFUNCTION()
    void DecreaseHealth(int Amount){
        CurrentHealth -= Amount;
    }

    UFUNCTION()
    void IncreaseHealth(int Amount){
        CurrentHealth += Amount;
        if(CurrentHealth > MaxHealth)
            CurrentHealth = MaxHealth;
    }
}