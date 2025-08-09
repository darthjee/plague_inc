# frozen_string_literal: true

shared_context 'with instant incomplete' do |day|
  before do
    instant = create(:contagion_instant, day: day, contagion: contagion)

    create(
      :contagion_population, :infected,
      size: (2 * day) + 2,
      instant: instant,
      group: group,
      days: 0
    )

    if day > 0
      create(
        :contagion_population, :dead,
        size: day,
        instant: instant,
        group: group,
        days: 0
      )
      create(
        :contagion_population, :immune,
        size: day,
        instant: instant,
        group: group,
        days: 0
      )
    end

    if day > 1
      create(
        :contagion_population, :dead,
        size: day - 1,
        instant: instant,
        group: group,
        days: 1
      )
      create(
        :contagion_population, :immune,
        size: day - 1,
        instant: instant,
        group: group,
        days: 1
      )
    end
  end
end

shared_context 'with instant complete' do |day|
  include_context 'with instant incomplete', day

  before do
    instant = contagion.reload.instants.find_by(day: day)

    create(
      :contagion_population, :healthy,
      size: size - instant.populations.sum(:size),
      instant: instant,
      group: group,
      new_infections: (2 * day) + 4,
      days: day
    )
  end
end

shared_context 'with instant with empty populations' do |day, size: 0|
  include_context 'with instant incomplete', day

  before do
    instant = contagion.reload.instants.find_by(day: day)

    create(
      :contagion_population, :healthy,
      size: size,
      instant: instant,
      group: group,
      new_infections: 0,
      days: day
    )
  end
end
