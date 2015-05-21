RSpec::Matchers.define :have_transition do |transition|
  match do |model|
    transition = OpenStruct(transition)
    events = model.class.state_machines[transition.state_field].events
    event = events[transition.name]

    events.valid_for(model, :from => transition.from, :to => transition.to) == [event]
  end

  def OpenStruct(params)
    params.is_a?(OpenStruct) ? params : OpenStruct.new(params)
  end
end