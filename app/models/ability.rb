class Ability
  include CanCan::Ability

  def initialize(user)
    user ? admin_rules : guest_rules
  end

  def admin_rules
    admin.roles.each do |role|
      exec_role_rules(role) if admin.roles.include? role
    end

    default_rules
  end

  def exec_role_rules role
    meth = :"#{role}_rules"
    send(meth) if respond_to? meth
  end

  # rule methods for each role
  def administrator_rules
    can :manage, :all
  end

  def doctor_rules
  end

  def health_worker_rules
  end

  # rule methods for guest and default
  def default_rules
    can :read, :all
  end

end
