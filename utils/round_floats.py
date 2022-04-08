from re import sub, search


input_file = "scenes/Levels/Base/BaseDay1.tscn"


def main():
    with open(input_file, "r+") as f:
        lines = f.readlines()
        f.seek(0)
        for line in lines:
            result = search(r"Vector2\( [-\d\.]+, [-\d\.]+ \)", line)
            if result is not None:
                vector_str = line[result.start():result.end()]
                subbed = sub(
                    r" (-?[\d\.]+)", lambda x: f" {round(float(x.group()))}", vector_str)
                f.write(line[:result.start()] +
                        subbed + line[result.end():])
            else:
                f.write(line)
        f.truncate()


if __name__ == "__main__":
    main()
