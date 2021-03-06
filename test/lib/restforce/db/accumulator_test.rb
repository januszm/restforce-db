require_relative "../../../test_helper"

describe Restforce::DB::Accumulator do

  configure!

  let(:accumulator) { Restforce::DB::Accumulator.new }

  describe "#store" do
    let(:timestamp) { Time.now }
    let(:changes) { { one_fish: "Two Fish", red_fish: "Blue Fish" } }

    before do
      accumulator.store(timestamp, changes)
    end

    it "stores the passed changeset in the accumulator" do
      expect(accumulator[timestamp]).to_equal changes
    end

    describe "for a pre-existing timestamp" do
      let(:new_changes) { { old_fish: "New Fish" } }

      before do
        accumulator.store(timestamp, new_changes)
      end

      it "updates the existing changeset in the accumulator" do
        expect(accumulator[timestamp]).to_equal changes.merge(new_changes)
      end
    end
  end

  describe "#attributes" do
    let(:timestamp) { Time.now }
    let(:changes) { { one_fish: "Two Fish", red_fish: "Blue Fish" } }

    before do
      accumulator.store(timestamp, changes)
    end

    it "returns the attributes from the recorded changeset" do
      expect(accumulator.attributes).to_equal changes
    end

    it "combines multiple changesets" do
      additional_changes = { hootie: "Blow Fish" }

      accumulator.store Time.now, additional_changes
      expect(accumulator.attributes).to_equal changes.merge(additional_changes)
    end

    describe "with conflicting changesets" do
      let(:new_changes) { { one_fish: "No Fish", red_fish: "Glow Fish" } }

      it "respects the most recently updated values" do
        accumulator.store timestamp + 1, new_changes
        expect(accumulator.attributes).to_equal new_changes
      end

      it "ignores less recently updated values" do
        accumulator.store timestamp - 1, new_changes
        expect(accumulator.attributes).to_equal changes
      end
    end
  end

  describe "#current" do
    let(:attributes) { { wocket: "Pocket", jertain: "Curtain", zelf: "Shelf" } }

    before do
      accumulator.store(Time.now, attributes)
    end

    it "returns the current values for all attributes in the passed hash" do
      expect(accumulator.current(wocket: "Locket")).to_equal(wocket: "Pocket")
      expect(accumulator.current(jertain: "Curtain", zelf: "Belfrey")).to_equal(
        jertain: "Curtain",
        zelf: "Shelf",
      )
    end
  end

  describe "#changed?" do
    let(:attributes) { { wocket: "Pocket", jertain: "Curtain", zelf: "Shelf" } }

    before do
      accumulator.store(Time.now, attributes)
    end

    it "returns true if there are changes in the passed attributes hash" do
      expect(accumulator).to_be :changed?, wocket: "Locket", zelf: "Shelf"
    end

    it "ignores attributes not set in both the Accumulator and the passed Hash" do
      expect(accumulator).to_not_be :changed?, yottle: "Bottle"
    end
  end

  describe "#up_to_date_for?" do
    let(:timestamp) { Time.now }

    before do
      accumulator.store(timestamp, some: "set", of: "attributes")
    end

    it "returns true if the passed timestamp is less recent than the stored time" do
      expect(accumulator).to_be :up_to_date_for?, timestamp - 1
    end

    it "returns true if the passed timestamp is identical to the stored time" do
      expect(accumulator).to_be :up_to_date_for?, timestamp
    end

    it "returns false if the passed timestamp is more recent than the stored time" do
      expect(accumulator).to_not_be :up_to_date_for?, timestamp + 1
    end
  end

end
