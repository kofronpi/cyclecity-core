require "rails_helper"

describe VelocitasCore::GpxImporter do
  let(:file) { File.new('spec/fixtures/simple.gpx') }
  let!(:activity) { create :activity, key: "run" }
  let(:uri) { "https://www.filepicker.io/api/file/a8gK5AgGSKaYqKY26F0w" }

  subject { described_class.new(file, uri) }

  describe "#import" do
    context "for the parent track" do
      it "creates a Track in the db" do
        expect {
          subject.import
        }.to change { Track.count }.by(1)
      end

      it "creates a track with the file name as the title by default" do
        subject.import
        expect(Track.last.title).to eq "simple"
      end

      it "adds an activity type of running for the default" do
        subject.import
        expect(Track.last.activity).to be_run
      end

      it "adds the URI of the cloud file for the default" do
        subject.import
        expect(Track.last.file_uri).to eq uri
      end
    end

    context "importing each point" do
      it "loads up TrackPoints from the GPX file into the DB" do
        expect {
          subject.import
        }.to change { TrackPoint.count }.by(2)
      end

      context "with correct data" do
        let(:point) { TrackPoint.last }

        before do
          subject.import
        end

        it "imports points with correct elevation" do
          expect(point.elevation).to eq 20.0
        end

        it "imports points with correct time" do
          expect(point.time).to eq Time.parse("2015-01-01T00:01:00Z")
        end

        it "imports points with correct latitude" do
          expect(point.coordinate.y).to eq 20.0
        end

        it "imports points with correct longitude" do
          expect(point.coordinate.x).to eq 25.0
        end
      end
    end
  end
end
