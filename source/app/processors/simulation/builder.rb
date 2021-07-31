# frozen_string_literal: true

class Simulation < ApplicationRecord
  # @author darhtjee
  #
  # Builds simulation from ActionController::Parameters
  # from a request
  class Builder
    include ::Processor
    include Arstotzka

    expose :simulation, after: :build_simulation
    expose :algorithm,  path: :simulation
    expose :settings,   path: :simulation,
                        after: :build_settings
    expose :groups,     path: 'simulation.settings',
                        after_each: :build_group,
                        default: []
    expose :behaviors,  path: 'simulation.settings',
                        after_each: :build_behavior,
                        default: []
    expose :sizes,      full_path: 'simulation.settings.groups.size',
                        default: []
    expose :lethality,  path: 'simulation.settings'
    expose :tags,       path: :simulation,
                        after: :build_default_tags,
                        after_each: :build_tag,
                        default: []

    # @param params [ActionController::Parameters]
    # @param simulations [Simulation::ActiveRecord_Relation]
    #   scope of creation
    def initialize(params, simulations)
      @params      = params
      @simulations = simulations
    end

    # Builds one simulatiom from params
    #
    # Simulation will be built within a certain scope
    #
    # @return [Simulation]
    def process
      groups
      behaviors
      settings
      simulation
    end

    private

    attr_reader :params, :simulations

    def build_simulation(simulation_params)
      build_object(
        simulation_params, simulations, Simulation,
        tags: tags
      )
    end

    def build_settings(settings_params)
      return unless algorithm
      return simulation.build_contagion unless settings_params

      simulation.build_contagion(
        settings_params.permit(Simulation::Contagion::ALLOWED_ATTRIBUTES)
      )
    end

    def build_group(group_params)
      group_behavior = behaviors.find do |behavior|
        behavior.reference == group_params[:behavior]
      end

      build_object(
        group_params, settings.groups,
        Simulation::Contagion::Group,
        behavior: group_behavior
      )
    end

    def build_behavior(behavior_params)
      build_object(
        behavior_params, settings.behaviors, Simulation::Contagion::Behavior,
        contagion: settings
      )
    end

    def build_tag(name)
      return unless name.present?

      Tag.for(name)
    end

    def build_default_tags(tags)
      tags << Tag.for("size:#{sizes.sum}")
      tags << Tag.for("lethality:#{lethality}")
    end

    def build_object(params, collection, klass, **attributes)
      collection.build(
        params.permit(klass::ALLOWED_ATTRIBUTES)
        .merge(**attributes)
      )
    end

    def settings_class
      Simulation.const_get(algorithm.capitalize)
    end
  end
end
