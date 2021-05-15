require 'spec_helper'

fdescribe "Simple Contagion" do
  let(:params) do
    {
      simulation: {
        name: 'my simulation',
        algorithm: 'contagion',
        settings: {
          lethality: 1,
          days_till_recovery: 1,
          days_till_sympthoms: 0,
          days_till_start_death: 1,
          days_till_contagion: 0,
          groups: [{
            behavior: '1',
            infected: '1',
            name: 'Generic',
            reference: '1',
            size: '1000'
          }],
          behaviors: [{
            contagion_risk: '1',
            interactions: '2',
            name: 'Generic',
            reference: '1'
          }],
        }
      }
    }
  end

  let(:parsed_body) do
    JSON.parse(response.body)
  end

  let(:simulation_id) { parsed_body['id'] }

  before do
    post "/simulations.json", params: params
  end

  it 'creates simulation' do
    expect(simulation_id).not_to be_nil
  end
end
