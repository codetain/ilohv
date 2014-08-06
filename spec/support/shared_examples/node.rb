shared_examples_for "a node" do
  let(:factory_name) { described_class.name.demodulize.downcase }

  describe "validations" do
    describe "name" do
      it "requires a name" do
        node = build(factory_name, name: nil)

        expect(node).to_not be_valid
        expect(node.errors[:name].size).to eq 1
      end

      describe "unique path" do
        it "prevents a node with the same path as another from being created" do
          node = build(factory_name)
          allow(node).to receive(:other_with_same_path?) { true }

          expect(node).to_not be_valid
          expect(node.errors[:name].size).to eq 1
        end

        it "prevents an existing node to be renamed to have the same path as another" do
          node = create(factory_name)
          allow(node).to receive(:other_with_same_path?) { true }

          expect(node).to_not be_valid
          expect(node.errors[:name].size).to eq 1
        end
      end
    end
  end

  describe "callbacks" do
    describe "#calculate_full_path" do
      it "calculates the full path based on the parent" do
        allow(subject).to receive(:parent_full_path) { 'foo/bar' }
        allow(subject).to receive(:slug) { 'bam' }

        subject.valid?

        expect(subject.full_path).to eq 'foo/bar/bam'
      end
    end
  end

  describe "scopes" do
    describe "default scope" do
      it "orders nodes by name" do
        directory = create(:directory)

        node_2 = create(factory_name, parent: directory, name: 'node_2')
        node_1 = create(factory_name, parent: directory, name: 'node_1')

        expect(directory.children.to_a).to eq [node_1, node_2]
      end
    end
  end
end
