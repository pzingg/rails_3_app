class Ability
  include CanCan::Ability

  def initialize(user)
    if !user || user.anonymous?
      can :create, User
    elsif user.admin?
      can :manage, :all
    else
      can :update, User, :id => user.id
    end
  end
end