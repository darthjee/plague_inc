# frozen_string_literal: true

require 'spec_helper'

describe Simulation, type: :model do
  subject(:simulation) { build(:simulation) }

  describe 'validations' do
    it do
      expect(simulation).to validate_presence_of(:name)
    end

    it do
      expect(simulation).to validate_length_of(:name)
        .is_at_most(255)
    end

    it do
      expect(simulation).to validate_presence_of(:algorithm)
    end

    it do
      expect(simulation).to validate_inclusion_of(:algorithm)
        .in_array(described_class::ALGORITHMS)
    end

    it do
      expect(simulation).to validate_presence_of(:settings)
    end

    it do
      expect(simulation).to validate_presence_of(:status)
    end

    it do
      expect(simulation).to validate_inclusion_of(:status)
        .in_array(described_class::STATUSES)
    end
  end

  describe '#settings' do
    context 'when simulation has no settings at all' do
      subject(:simulation) { build(:simulation, contagion: nil) }

      it { expect(simulation.settings).to be_nil }
    end

    context 'when simulation has contagion' do
      subject(:simulation) { build(:simulation) }

      it { expect(simulation.settings).to be_a(Simulation::Contagion) }

      it { expect(simulation.settings).to eq(simulation.contagion) }
    end
  end

  describe '#settings=' do
    context 'when settings is a contagion' do
      let(:settings) { build(:contagion, simulation: nil) }

      it do
        expect { simulation.settings = settings }
          .to change(simulation, :contagion)
      end
    end
  end

  describe '#finished?' do
    subject(:simulation) { create(:simulation, status: status) }

    context 'when it is finished' do
      let(:status) { described_class::FINISHED }

      it { expect(simulation).to be_finished }
    end

    context 'when it is not finished' do
      let(:status) { statuses.sample }
      let(:statuses) do
        described_class::STATUSES -
          [described_class::FINISHED]
      end

      it { expect(simulation).not_to be_finished }
    end
  end

  describe '#processing?' do
    subject(:simulation) { create(:simulation, status: status) }

    context 'when it is processing' do
      let(:status) { described_class::PROCESSING }

      it { expect(simulation).to be_processing }
    end

    context 'when it is not processing' do
      let(:status) { statuses.sample }
      let(:statuses) do
        described_class::STATUSES -
          [described_class::PROCESSING]
      end

      it { expect(simulation).not_to be_processing }
    end
  end

  describe '#processable' do
    subject(:simulation) do
      create(
        :simulation,
        status: status,
        created_at: 1.hour.ago,
        updated_at: updated_at
      )
    end

    let(:updated_at) { Time.now }

    context 'when it is processing' do
      let(:status) { described_class::PROCESSING }

      context 'when it has just been updated' do
        it { expect(simulation).not_to be_processable }
      end

      context 'when it has just been updated a second ago' do
        let(:updated_at) { 1.second.ago }

        it { expect(simulation).not_to be_processable }
      end

      context 'when it has been updated a long time ago' do
        let(:updated_at) { Settings.processing_timeout.ago }

        it { expect(simulation).to be_processable }
      end
    end

    context 'when it is not processing' do
      let(:status) { statuses.sample }
      let(:statuses) do
        described_class::STATUSES -
          [described_class::PROCESSING]
      end

      context 'when it has just been updated' do
        it { expect(simulation).to be_processable }
      end

      context 'when it has just been updated a second ago' do
        let(:updated_at) { 1.second.ago }

        it { expect(simulation).to be_processable }
      end
    end
  end

  describe '#processable_in' do
    subject(:simulation) do
      create(
        :simulation,
        status: status,
        created_at: 1.hour.ago,
        updated_at: updated_at
      )
    end

    let(:updated_at) { Time.now }

    context 'when it is processing' do
      let(:status) { described_class::PROCESSING }
      let(:minimum_time) do
        Settings.processing_timeout - 2.seconds
      end
      let(:expected_range) do
        (minimum_time..Settings.processing_timeout)
      end

      context 'when it has just been updated' do
        it do
          expect(simulation.processable_in)
            .to be_in(expected_range)
        end
      end

      context 'when it has just been updated a second ago' do
        let(:updated_at) { 1.second.ago }

        it do
          expect(simulation.processable_in)
            .to be_in(expected_range)
        end
      end

      context 'when it has been updated a long time ago' do
        let(:updated_at) { Settings.processing_timeout.ago }

        it { expect(simulation.processable_in).to be_zero }
      end
    end

    context 'when it is not processing' do
      let(:status) { statuses.sample }
      let(:statuses) do
        described_class::STATUSES -
          [described_class::PROCESSING]
      end

      context 'when it has just been updated' do
        it { expect(simulation.processable_in).to be_zero }
      end
    end
  end

  describe '#attach_tag' do
    subject!(:simulation) { build(:simulation, tags: tags) }

    let(:tags) { [] }
    let(:name) { 'My tag_Name' }

    context 'when there is no tag registered' do
      it 'attach new tag to simulation' do
        expect { simulation.attach_tag(name) }
          .to change { simulation.tags.size }
          .by(1)
      end

      it 'does not save simulation' do
        simulation.attach_tag(name)

        expect(simulation).not_to be_persisted
      end

      it do
        expect { simulation.attach_tag(name) }
          .not_to change(Tag, :count)
      end
    end

    context 'when the tag is registered but not attached' do
      before { create(:tag, name: name) }

      it 'attach new tag to simulation' do
        expect { simulation.attach_tag(name) }
          .to change { simulation.tags.size }
          .by(1)
      end

      it 'does not save simulation' do
        simulation.attach_tag(name)

        expect(simulation).not_to be_persisted
      end

      it do
        expect { simulation.attach_tag(name) }
          .not_to change(Tag, :count)
      end
    end

    context 'when the tag is registered and attached' do
      let(:tags) { [name] }

      it 'does not attach new tag to simulation' do
        expect { simulation.attach_tag(name) }
          .not_to(change { simulation.tags.size })
      end

      it 'does not save simulation' do
        simulation.attach_tag(name)

        expect(simulation).not_to be_persisted
      end

      it do
        expect { simulation.attach_tag(name) }
          .not_to change(Tag, :count)
      end
    end
  end

  describe '#add_tag' do
    subject!(:simulation) { create(:simulation, tags: tags) }

    let(:tags) { [] }
    let(:name) { 'My tag_Name' }

    context 'when there is no tag registered' do
      it 'adds new tag to simulation' do
        expect { simulation.add_tag(name) }
          .to change { simulation.reload.tags.count }
          .by(1)
      end

      it do
        expect { simulation.add_tag(name) }
          .to change(Tag, :count)
          .by(1)
      end

      it 'normalizes tag name' do
        simulation.add_tag(name)

        expect(simulation.tags.pluck(:name))
          .to eq(['my tag_name'])
      end
    end

    context 'when the tag is registered but not attached' do
      before { create(:tag, name: name) }

      it 'adds new tag to simulation' do
        expect { simulation.add_tag(name) }
          .to change { simulation.reload.tags.count }
          .by(1)
      end

      it do
        expect { simulation.add_tag(name) }
          .not_to change(Tag, :count)
      end
    end

    context 'when the tag is registered and attached' do
      let(:tags) { [name] }

      it 'does not add tag to simulation' do
        expect { simulation.add_tag(name) }
          .not_to(change { simulation.reload.tags.count })
      end

      it do
        expect { simulation.add_tag(name) }
          .not_to change(Tag, :count)
      end
    end

    context 'when adding many tags' do
      it 'adds new tag to simulation' do
        expect { simulation.add_tag(name, 'oTherTag') }
          .to change { simulation.reload.tags.count }
          .by(2)
      end

      it do
        expect { simulation.add_tag(name, 'oTherTag') }
          .to change(Tag, :count)
          .by(2)
      end

      it 'normalizes tag name' do
        simulation.add_tag(name, 'oTherTag')

        expect(simulation.tags.pluck(:name))
          .to eq(['my tag_name', 'othertag'])
      end
    end
  end
end
