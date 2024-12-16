class Role < ApplicationRecord
    has_many :users

    enum name: { head: "Head", member_adult: "Member (Adult)", member_child: "Member (Child)" }

    

end
