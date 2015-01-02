Canard::Abilities.for(:guest) do
  can [:create, :activate], User
end