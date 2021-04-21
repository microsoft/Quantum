// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#nullable enable

#r "nuget: YamlDotNet, 11.1.3-nullable-enums-0003"
#r "nuget: System.CommandLine, 2.0.0-beta1.21216.1"
#r "nuget: Markdig, 0.24.0"

using Markdig;
using YamlDotNet;
using System.CommandLine;
using System.CommandLine.Invocation;
using Markdig.Syntax;
using Markdig.Extensions.Yaml;
using YamlDotNet.RepresentationModel;
using System.Collections.Immutable;
using Markdig.Parsers;
using Markdig.Renderers.Roundtrip;

readonly MarkdownPipeline Pipeline = new MarkdownPipelineBuilder()
    .UseYamlFrontMatter()
    .EnableTrackTrivia()
    .Build();

readonly ImmutableHashSet<string> AllowedKeys =
    new HashSet<string>
    {
        "page_type",
        "languages",
        "products",
        "description",
        "urlFragment",
    }
    .ToImmutableHashSet();

var command = new RootCommand
{
    new Argument<string>(
        "path",
        "Path to file whose YAML frontmatter should be filtered."
    ),

    new Argument<string>(
        "out",
        "Path to write new Markdown document to."
    ),
};

command.Handler = CommandHandler.Create<string, string>(
    async (path, outPath) =>
    {
        // Read all contents of the given path.
        var contents = await File.ReadAllTextAsync(path);
        var document = Markdown.Parse(contents, pipeline: Pipeline);
        var frontMatterBlock = document.Descendants<YamlFrontMatterBlock>().FirstOrDefault();

        if (frontMatterBlock == null)
        {
            // No frontmatter to strip.
            return;
        }

        var yaml = new YamlStream();
        yaml.Load(new StringReader(frontMatterBlock.Lines.ToString()));
        var frontMatter = yaml.Documents[0];

        var mapping = (YamlMappingNode)frontMatter.RootNode;
        var newMapping = new YamlMappingNode();

        foreach (var entry in mapping.Children)
        {
            if (entry.Key is YamlScalarNode scalar && scalar.Value is {} key && AllowedKeys.Contains(key))
            {
                newMapping.Add(entry.Key, entry.Value);
            }
        }
        document.Remove(frontMatterBlock);

        using var frontMatterStream = new StringWriter();
        new YamlDotNet.Serialization.SerializerBuilder()
            .Build()
            .Serialize(frontMatterStream, newMapping);
        var newFrontMatter = frontMatterStream.ToString();
        using var outStream = new StringWriter();
        var newMarkdown = new RoundtripRenderer(outStream).Render(document);

        await File.WriteAllTextAsync(outPath, $"---\n{newFrontMatter}---\n{newMarkdown}");
    }
);

await command.InvokeAsync(Args.ToArray());
