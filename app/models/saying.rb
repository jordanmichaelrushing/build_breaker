class Saying < ActiveRecord::Base
  BURNS = [
    'You should rethink your life choices!',
    '. . . . . . . . . . . . . Who hired you?',
    pluck(:msg)
  ].flatten
end
