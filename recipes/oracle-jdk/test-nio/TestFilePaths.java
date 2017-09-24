import java.nio.file.Paths;
import java.lang.IllegalArgumentException;

public class TestFilePaths {
	public static void main(String[] args) {
		if (args.length == 0) {
			throw new IllegalArgumentException("Args.length > 0");
		}
                for (String path: args) {
			Paths.get(path);
		}
		return;
	}
}
