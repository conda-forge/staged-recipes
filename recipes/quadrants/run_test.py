import quadrants as qd


@qd.kernel
def fill_array(values: qd.types.NDArray[qd.i32, 1]) -> None:
    for i in range(4):
        values[i] = i + 1


def main() -> None:
    qd.init(arch=qd.cpu)
    try:
        values = qd.ndarray(qd.int32, (4,))
        fill_array(values)
        assert values.to_numpy().tolist() == [1, 2, 3, 4]
    finally:
        qd.reset()


if __name__ == "__main__":
    main()
