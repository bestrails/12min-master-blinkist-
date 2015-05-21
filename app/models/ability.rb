class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user 
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. 
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities

    if user.superuser?
      can :manage, :all
    else
      can :read, Discount do |discount|
        !user.discount_codes.include?(discount.code)
      end

      unless user.subscription.actived?
        cannot :manage, :all
      else
        can :read, Book do |book|
          user.library.books.include?(book)
        end

        can :pocket, Book do |book|
          user.library.books.include?(book) && user.subscription.pocket < user.subscription.plan.pocket_limit
        end

        can :kindle, Book do |book|
          user.library.books.include?(book) && user.subscription.kindle < user.subscription.plan.kindle_limit
        end

        can :pick, Book

        if user.subscription.plan.is_trial?
          can :pick, Book do |book|
            user.library.books.count < user.subscription.plan.books_limit
          end
        end
      end
    end
  end
end
