import fs from "node:fs";
import path from "node:path";

const [inputPath, outputPath, ...extraLicensePaths] = process.argv.slice(2);

if (!inputPath || !outputPath) {
  throw new Error(
    "Usage: generate-third-party-licenses.mjs INPUT OUTPUT [EXTRA_LICENSE ...]",
  );
}

const groupedDependencies = JSON.parse(fs.readFileSync(inputPath, "utf8"));
const dependencies = Object.entries(groupedDependencies)
  .flatMap(([license, packages]) =>
    packages.map((pkg) => ({ ...pkg, license: pkg.license || license })),
  )
  .sort((left, right) => {
    const byName = left.name.localeCompare(right.name);
    return byName || left.versions.join(",").localeCompare(right.versions.join(","));
  });

if (dependencies.length === 0) {
  throw new Error("pnpm returned no production dependencies");
}

const licenseNamePattern =
  /^(license|licence|copying|notice|copyright|ofl)([-._].*)?$/i;
const licenseGroups = new Map();
const dependenciesWithoutLicenseText = [];

for (const dependency of dependencies) {
  const label = `${dependency.name}@${dependency.versions.join(", ")}`;
  let licenseFiles = [];

  const packagePaths = [
    ...dependency.paths,
    path.resolve("node_modules", dependency.name),
  ];

  for (const packagePath of packagePaths) {
    if (!fs.existsSync(packagePath)) {
      continue;
    }

    licenseFiles = fs
      .readdirSync(packagePath, { withFileTypes: true })
      .filter(
        (entry) =>
          (entry.isFile() || entry.isSymbolicLink()) &&
          licenseNamePattern.test(entry.name),
      )
      .map((entry) => path.join(packagePath, entry.name))
      .sort();

    if (licenseFiles.length > 0) {
      break;
    }
  }

  if (licenseFiles.length === 0) {
    dependenciesWithoutLicenseText.push(label);
    continue;
  }

  const licenseText = licenseFiles
    .map((licensePath) => fs.readFileSync(licensePath, "utf8").trim())
    .filter(Boolean)
    .join("\n\n");

  if (!licenseText) {
    dependenciesWithoutLicenseText.push(label);
    continue;
  }

  const existing = licenseGroups.get(licenseText) ?? [];
  existing.push(label);
  licenseGroups.set(licenseText, existing);
}

const lines = [
  "THIRD-PARTY SOFTWARE NOTICES",
  "============================",
  "",
  "Production dependencies bundled with Emdash:",
  "",
  ...dependencies.map(
    (dependency) =>
      `- ${dependency.name}@${dependency.versions.join(", ")} — ${dependency.license}`,
  ),
  "",
  "LICENSE TEXTS",
  "=============",
  "",
];

for (const [licenseText, packages] of licenseGroups) {
  lines.push(
    `Applies to: ${packages.join(", ")}`,
    "-".repeat(80),
    licenseText,
    "",
  );
}

if (dependenciesWithoutLicenseText.length > 0) {
  lines.push(
    "DEPENDENCIES WITHOUT A DISTRIBUTED LICENSE FILE",
    "===============================================",
    "",
    "Their declared license identifiers are recorded in the dependency list above.",
    "",
    ...dependenciesWithoutLicenseText.map((dependency) => `- ${dependency}`),
    "",
  );
}

for (const extraLicensePath of extraLicensePaths) {
  lines.push(
    `BUNDLED RUNTIME NOTICE: ${path.basename(extraLicensePath)}`,
    "=".repeat(80),
    "",
    fs.readFileSync(extraLicensePath, "utf8").trim(),
    "",
  );
}

if (licenseGroups.size === 0) {
  throw new Error("No dependency license texts were found");
}

fs.writeFileSync(outputPath, `${lines.join("\n")}\n`);
