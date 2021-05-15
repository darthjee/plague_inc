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
  let(:simulation)    { Simulation.find(simulation_id) }
  let(:contagion)     { simulation.contagion }

  before do
    post "/simulations.json", params: params
  end

  it 'creates simulation' do
    expect(simulation_id).not_to be_nil
  end

  context 'when processing' do
    let(:first_instant) do
      contagion.instants.first
    end

    let(:new_instant) do
      contagion.reload.instants.last
    end

    let(:new_populations) do
      new_instant.populations
    end

    before do
      processing_times.times do
        post "/simulations/#{simulation_id}/contagion/process.json", params: {}
      end
    end

    context 'when processing only once' do
      let(:processing_times) { 1 }

      it "creates first instant" do
        expect(first_instant).to be_ready
      end

      it "marks simulation as processed" do
        expect(simulation.reload).to be_processed
      end
    end

    context 'when processing twice' do
      let(:processing_times) { 2 }

      it "creates second instant" do
        expect(new_instant).to be_ready
      end

      it 'infects more healthy people' do
        expect(new_populations.infected.sum(:size)).to be > 1
      end

      it 'marks first instant as processed' do
        expect(first_instant).to be_processed
      end

      it "marks simulation as processed" do
        expect(simulation.reload).to be_processed
      end
    end

    context 'when processing three' do
      let(:processing_times) { 3 }

      it "creates a third instant" do
        expect(contagion.instants.count).to eq(3)
      end

      it 'infects more healthy people' do
        expect(new_populations.infected.sum(:size)).to be > 2
      end

      it "marks simulation as processed" do
        expect(simulation.reload).to be_processed
      end
    end

    context 'when processing three with a reduced block size' do
      let(:processing_times) { 3 }
      let(:current_instant)  { contagion.reload.instants.find_by(day: 2) }
      let(:processing_params) do
        {
          options: {
            interaction_block_size: 1
          }
        }
      end

      before do
        post "/simulations/#{simulation_id}/contagion/process.json", params: processing_params
      end

      it "creates a forth instant" do
        expect(contagion.instants.count).to eq(4)
      end

      it "marks forth instant as created" do
        expect(new_instant).to be_created
      end

      it "marks current instant as processing" do
        expect(current_instant.reload).to be_processing
      end

      it 'infects more healthy people' do
        expect(new_populations.infected.sum(:size)).to be > 0
      end

      it "marks simulation as processed" do
        expect(simulation.reload).to be_processed
      end
    end
  end
end
